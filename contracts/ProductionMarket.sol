// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ProductionMarket - On-Chain Hardware Design Protocol
 * @notice A positive-sum alternative to prediction markets for hardware innovation.
 *         Every 3D recombination is an on-chain transaction.
 *         Agents and humans are equal — pay to create, fork, or remix.
 *
 *         CREATE  → new original design         (higher cost)
 *         FORK    → copy & modify someone's     (auto royalty to original)
 *         REMIX   → recombine parts from many   (auto royalty to all sources)
 *
 *         Each design carries an intrinsic complexity score:
 *         complexityScore = structureScore × electronicScore × logicScore  (n³)
 *         Computed off-chain, committed on-chain with hash verification.
 *
 * @dev Deployed on Base for The Synthesis Hackathon 2026.
 *      Agent Identity: ERC-8004 #29549
 */
contract ProductionMarket {

    // =========== ENUMS ===========

    enum ActionType { CREATE, FORK, REMIX }

    // =========== STRUCTS ===========

    struct Design {
        uint256 id;
        address creator;          // ERC-8004 agent or human wallet
        string  name;             // e.g. "4-DOF Robotic Arm"
        string  contentHash;      // IPFS hash of design files
        string  prompt;           // the natural language prompt used
        uint256 parentId;         // 0 = original, >0 = forked from
        uint256[] sourceIds;      // remix: multiple parent sources
        uint256 forkCount;        // how many times this was forked
        uint256 remixCount;       // how many remixes reference this
        uint256 totalRoyalties;   // total royalties earned (in wei)
        uint256 paidAmount;       // how much was paid to create this
        uint256 createdAt;
        ActionType action;        // CREATE, FORK, or REMIX
        bool    exists;
        // --- n³ Complexity Metrics ---
        uint8   structureScore;   // 3D structure: parts, joints, DOF, transmission depth
        uint8   electronicScore;  // electronics: actuators, sensors, cubes
        uint8   logicScore;       // code/logic: states, behaviors, feedback loops
        uint32  complexityScore;  // structure × electronic × logic (the n³)
        bytes32 metricsHash;      // hash(scores + algorithm version) for verification
    }

    // =========== STATE ===========

    uint256 public nextDesignId = 1;
    mapping(uint256 => Design) public designs;
    mapping(address => uint256[]) public designsByCreator;

    // --------- Tiered Pricing ---------
    // ~$0.01 minimum for remix, ~$0.05 for fork, ~$0.10 for create
    // Using fixed ETH amounts for hackathon demo
    uint256 public constant CREATE_FEE = 0.00005 ether;  // ~$0.10 at ~$2k/ETH
    uint256 public constant FORK_FEE   = 0.000025 ether;  // ~$0.05
    uint256 public constant REMIX_FEE  = 0.000005 ether;  // ~$0.01

    // --------- Revenue Split (basis points) ---------
    uint256 public constant ROYALTY_BPS  = 500;   // 5% to original creator
    uint256 public constant PARENT_BPS   = 250;   // 2.5% to direct parent
    uint256 public constant PLATFORM_BPS = 1500;  // 15% to platform

    address public platform;
    address public owner;

    // --------- Counters ---------
    uint256 public totalPaid;          // total ETH ever paid into this contract
    uint256 public totalRoyaltiesPaid; // total royalties distributed

    // =========== EVENTS ===========

    event DesignAction(
        uint256 indexed designId,
        address indexed actor,
        ActionType      action,
        string          name,
        string          prompt,
        uint256         amountPaid,
        uint32          complexityScore,
        uint256         timestamp
    );

    event RoyaltyPaid(
        uint256 indexed sourceDesignId,
        address indexed recipient,
        uint256 amount
    );

    event Remix(
        uint256 indexed   newDesignId,
        uint256[] sourceIds,
        address indexed   remixer,
        uint256            timestamp
    );

    // =========== CONSTRUCTOR ===========

    constructor() {
        owner = msg.sender;
        platform = msg.sender;
    }

    // =========== CORE: CREATE ===========

    /**
     * @notice Create a new original design. Costs CREATE_FEE.
     *         Agent or human pays → 3D design is registered on-chain.
     */
    function createDesign(
        string calldata _name,
        string calldata _contentHash,
        string calldata _prompt,
        uint8 _structureScore,
        uint8 _electronicScore,
        uint8 _logicScore,
        bytes32 _metricsHash
    ) external payable returns (uint256 designId) {
        require(msg.value >= CREATE_FEE, "Min $0.10 to create");

        designId = nextDesignId++;
        uint256[] memory empty = new uint256[](0);
        uint32 _complexity = uint32(_structureScore) * uint32(_electronicScore) * uint32(_logicScore);

        designs[designId] = Design({
            id:             designId,
            creator:        msg.sender,
            name:           _name,
            contentHash:    _contentHash,
            prompt:         _prompt,
            parentId:       0,
            sourceIds:      empty,
            forkCount:      0,
            remixCount:     0,
            totalRoyalties: 0,
            paidAmount:     msg.value,
            createdAt:      block.timestamp,
            action:         ActionType.CREATE,
            exists:         true,
            structureScore:  _structureScore,
            electronicScore: _electronicScore,
            logicScore:      _logicScore,
            complexityScore: _complexity,
            metricsHash:     _metricsHash
        });

        designsByCreator[msg.sender].push(designId);
        totalPaid += msg.value;

        // Platform gets the create fee
        _sendPlatformFee(msg.value);

        emit DesignAction(designId, msg.sender, ActionType.CREATE, _name, _prompt, msg.value, _complexity, block.timestamp);
    }

    // =========== CORE: FORK ===========

    /**
     * @notice Fork an existing design. Costs FORK_FEE.
     *         Auto-pays royalty to original creator.
     */
    function forkDesign(
        uint256 _parentId,
        string calldata _name,
        string calldata _contentHash,
        string calldata _prompt,
        uint8 _structureScore,
        uint8 _electronicScore,
        uint8 _logicScore,
        bytes32 _metricsHash
    ) external payable returns (uint256 newDesignId) {
        require(designs[_parentId].exists, "Parent design does not exist");
        require(msg.value >= FORK_FEE, "Min $0.05 to fork");

        // Pay royalties
        _payRoyalties(_parentId, msg.value);

        // Create forked design
        newDesignId = nextDesignId++;
        uint256[] memory empty = new uint256[](0);
        uint32 _complexity = uint32(_structureScore) * uint32(_electronicScore) * uint32(_logicScore);

        designs[newDesignId] = Design({
            id:             newDesignId,
            creator:        msg.sender,
            name:           _name,
            contentHash:    _contentHash,
            prompt:         _prompt,
            parentId:       _parentId,
            sourceIds:      empty,
            forkCount:      0,
            remixCount:     0,
            totalRoyalties: 0,
            paidAmount:     msg.value,
            createdAt:      block.timestamp,
            action:         ActionType.FORK,
            exists:         true,
            structureScore:  _structureScore,
            electronicScore: _electronicScore,
            logicScore:      _logicScore,
            complexityScore: _complexity,
            metricsHash:     _metricsHash
        });

        designs[_parentId].forkCount++;
        designsByCreator[msg.sender].push(newDesignId);
        totalPaid += msg.value;

        emit DesignAction(newDesignId, msg.sender, ActionType.FORK, _name, _prompt, msg.value, _complexity, block.timestamp);
    }

    // =========== CORE: REMIX (the $0.01 magic) ===========

    /**
     * @notice Remix: recombine parts from multiple existing designs.
     *         This is the $0.01 action — cheapest way to trigger 3D recombination.
     *         Royalties split across ALL source designers.
     */
    function remixDesign(
        uint256[] calldata _sourceIds,
        string calldata _name,
        string calldata _contentHash,
        string calldata _prompt,
        uint8 _structureScore,
        uint8 _electronicScore,
        uint8 _logicScore,
        bytes32 _metricsHash
    ) external payable returns (uint256 newDesignId) {
        require(_sourceIds.length > 0, "Need at least one source");
        require(msg.value >= REMIX_FEE, "Min $0.01 to remix");

        // Verify all sources exist
        for (uint256 i = 0; i < _sourceIds.length; i++) {
            require(designs[_sourceIds[i]].exists, "Source design does not exist");
        }

        // Split royalty equally among all source creators
        uint256 royaltyPerSource = (msg.value * ROYALTY_BPS) / (10000 * _sourceIds.length);
        for (uint256 i = 0; i < _sourceIds.length; i++) {
            address sourceCreator = designs[_sourceIds[i]].creator;
            if (sourceCreator != address(0) && royaltyPerSource > 0) {
                (bool sent, ) = sourceCreator.call{value: royaltyPerSource}("");
                if (sent) {
                    designs[_sourceIds[i]].totalRoyalties += royaltyPerSource;
                    totalRoyaltiesPaid += royaltyPerSource;
                    emit RoyaltyPaid(_sourceIds[i], sourceCreator, royaltyPerSource);
                }
            }
            designs[_sourceIds[i]].remixCount++;
        }

        // Platform fee
        _sendPlatformFee((msg.value * PLATFORM_BPS) / 10000);

        // Create remixed design
        newDesignId = nextDesignId++;
        uint32 _complexity = uint32(_structureScore) * uint32(_electronicScore) * uint32(_logicScore);

        designs[newDesignId] = Design({
            id:             newDesignId,
            creator:        msg.sender,
            name:           _name,
            contentHash:    _contentHash,
            prompt:         _prompt,
            parentId:       0,
            sourceIds:      _sourceIds,
            forkCount:      0,
            remixCount:     0,
            totalRoyalties: 0,
            paidAmount:     msg.value,
            createdAt:      block.timestamp,
            action:         ActionType.REMIX,
            exists:         true,
            structureScore:  _structureScore,
            electronicScore: _electronicScore,
            logicScore:      _logicScore,
            complexityScore: _complexity,
            metricsHash:     _metricsHash
        });

        designsByCreator[msg.sender].push(newDesignId);
        totalPaid += msg.value;

        emit DesignAction(newDesignId, msg.sender, ActionType.REMIX, _name, _prompt, msg.value, _complexity, block.timestamp);
        emit Remix(newDesignId, _sourceIds, msg.sender, block.timestamp);
    }

    // =========== VIEW FUNCTIONS ===========

    /**
     * @notice Get full design details by ID.
     */
    function getDesign(uint256 _designId) external view returns (Design memory) {
        require(designs[_designId].exists, "Design does not exist");
        return designs[_designId];
    }

    /**
     * @notice Get all design IDs created by a specific address.
     */
    function getDesignsByCreator(address _creator) external view returns (uint256[] memory) {
        return designsByCreator[_creator];
    }

    /**
     * @notice Get the full fork ancestry chain for a design.
     * @return ancestors Array of design IDs from the given design up to the root.
     */
    function getForkAncestry(uint256 _designId) external view returns (uint256[] memory) {
        uint256[] memory temp = new uint256[](100); // max depth 100
        uint256 count = 0;
        uint256 current = _designId;

        while (designs[current].exists && designs[current].parentId != 0) {
            temp[count++] = designs[current].parentId;
            current = designs[current].parentId;
        }

        uint256[] memory ancestors = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            ancestors[i] = temp[i];
        }
        return ancestors;
    }

    /**
     * @notice Get total number of designs registered.
     */
    function totalDesigns() external view returns (uint256) {
        return nextDesignId - 1;
    }

    // =========== INTERNAL ===========

    /**
     * @dev Walk up the fork chain to find the root (original) design.
     */
    function _findRoot(uint256 _designId) internal view returns (uint256) {
        uint256 current = _designId;
        while (designs[current].parentId != 0) {
            current = designs[current].parentId;
        }
        return current;
    }

    /**
     * @dev Pay royalties for a fork action.
     *      5% to root original creator, 2.5% to direct parent (if different).
     */
    function _payRoyalties(uint256 _parentId, uint256 _amount) internal {
        // Find the root
        uint256 rootId = _findRoot(_parentId);
        address rootCreator = designs[rootId].creator;

        // 5% to root creator
        uint256 rootRoyalty = (_amount * ROYALTY_BPS) / 10000;
        if (rootRoyalty > 0 && rootCreator != address(0)) {
            (bool sent, ) = rootCreator.call{value: rootRoyalty}("");
            if (sent) {
                designs[rootId].totalRoyalties += rootRoyalty;
                totalRoyaltiesPaid += rootRoyalty;
                emit RoyaltyPaid(rootId, rootCreator, rootRoyalty);
            }
        }

        // 2.5% to direct parent (if different from root)
        address parentCreator = designs[_parentId].creator;
        if (parentCreator != rootCreator && parentCreator != address(0)) {
            uint256 parentRoyalty = (_amount * PARENT_BPS) / 10000;
            if (parentRoyalty > 0) {
                (bool sent2, ) = parentCreator.call{value: parentRoyalty}("");
                if (sent2) {
                    designs[_parentId].totalRoyalties += parentRoyalty;
                    totalRoyaltiesPaid += parentRoyalty;
                    emit RoyaltyPaid(_parentId, parentCreator, parentRoyalty);
                }
            }
        }

        // Platform fee
        _sendPlatformFee((_amount * PLATFORM_BPS) / 10000);
    }

    /**
     * @dev Send platform fee. Silent fail to prevent blocking user transactions.
     */
    function _sendPlatformFee(uint256 _amount) internal {
        if (_amount > 0 && platform != address(0)) {
            (bool sent, ) = platform.call{value: _amount}("");
            // Silent fail for platform fee — don't block user transactions
            sent; // suppress unused variable warning
        }
    }

    // =========== ADMIN ===========

    function setPlatformAddress(address _platform) external {
        require(msg.sender == owner, "Only owner");
        platform = _platform;
    }
}
