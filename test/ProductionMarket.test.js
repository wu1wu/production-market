const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ProductionMarket", function () {
  let market, owner, alice, bob;
  const CREATE_FEE = ethers.parseEther("0.0001"); // $0.10 equiv
  const FORK_FEE = ethers.parseEther("0.00005");  // $0.05 equiv
  const REMIX_FEE = ethers.parseEther("0.00001"); // $0.01 equiv

  beforeEach(async function () {
    [owner, alice, bob] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("ProductionMarket");
    market = await Factory.deploy(owner.address);
    await market.waitForDeployment();
  });

  describe("CREATE", function () {
    it("should create a design with complexity scores", async function () {
      const metricsHash = ethers.keccak256(ethers.toUtf8Bytes("structure:3,electronic:1,logic:1,v1"));
      
      const tx = await market.connect(alice).createDesign(
        "Simple Gear Train",
        "QmSimpleGearTrainIPFSHash",
        "A simple gear reduction for slow rotation",
        3,  // structureScore
        1,  // electronicScore
        1,  // logicScore
        metricsHash,
        { value: CREATE_FEE }
      );

      const receipt = await tx.wait();
      const design = await market.designs(1);
      
      expect(design.name).to.equal("Simple Gear Train");
      expect(design.creator).to.equal(alice.address);
      expect(design.structureScore).to.equal(3);
      expect(design.electronicScore).to.equal(1);
      expect(design.logicScore).to.equal(1);
      expect(design.complexityScore).to.equal(3); // 3 × 1 × 1
      expect(design.exists).to.be.true;
    });

    it("should reject if fee too low", async function () {
      const metricsHash = ethers.keccak256(ethers.toUtf8Bytes("test"));
      await expect(
        market.connect(alice).createDesign("Test", "hash", "prompt", 1, 1, 1, metricsHash, { value: 0 })
      ).to.be.revertedWith("Min $0.10 to create");
    });
  });

  describe("FORK", function () {
    it("should fork a design and pay royalties", async function () {
      const hash1 = ethers.keccak256(ethers.toUtf8Bytes("v1"));
      const hash2 = ethers.keccak256(ethers.toUtf8Bytes("v2"));
      
      // Alice creates original
      await market.connect(alice).createDesign(
        "Original Arm", "QmOriginal", "robotic arm", 8, 3, 3, hash1,
        { value: CREATE_FEE }
      );

      // Bob forks with higher complexity
      const aliceBalBefore = await ethers.provider.getBalance(alice.address);
      
      await market.connect(bob).forkDesign(
        1, "Improved Arm", "QmImproved", "6-DOF arm", 12, 4, 5, hash2,
        { value: FORK_FEE }
      );

      const forked = await market.designs(2);
      expect(forked.parentId).to.equal(1);
      expect(forked.complexityScore).to.equal(240); // 12 × 4 × 5

      // Check that alice's design got fork count incremented
      const original = await market.designs(1);
      expect(original.forkCount).to.equal(1);

      // Alice should have received royalty
      const aliceBalAfter = await ethers.provider.getBalance(alice.address);
      expect(aliceBalAfter).to.be.gt(aliceBalBefore);
    });
  });

  describe("REMIX", function () {
    it("should remix multiple designs and split royalties", async function () {
      const hash = ethers.keccak256(ethers.toUtf8Bytes("v1"));
      
      // Alice creates design 1
      await market.connect(alice).createDesign(
        "Gripper", "QmGripper", "gripper mechanism", 5, 2, 2, hash,
        { value: CREATE_FEE }
      );

      // Bob creates design 2
      await market.connect(bob).createDesign(
        "Sensor Array", "QmSensor", "sensor module", 2, 5, 3, hash,
        { value: CREATE_FEE }
      );

      // Owner remixes both
      await market.connect(owner).remixDesign(
        [1, 2], "Smart Gripper", "QmSmart", "gripper with sensors", 8, 6, 5, hash,
        { value: REMIX_FEE }
      );

      const remixed = await market.designs(3);
      expect(remixed.complexityScore).to.equal(240); // 8 × 6 × 5

      // Both source designs should have remixCount = 1
      expect((await market.designs(1)).remixCount).to.equal(1);
      expect((await market.designs(2)).remixCount).to.equal(1);
    });
  });

  describe("Complexity Scoring", function () {
    it("should correctly compute n³ scores", async function () {
      const hash = ethers.keccak256(ethers.toUtf8Bytes("test"));
      
      // Static model: no electronics, no logic
      await market.connect(alice).createDesign(
        "Static Model", "Qm1", "display only", 5, 0, 0, hash,
        { value: CREATE_FEE }
      );
      expect((await market.designs(1)).complexityScore).to.equal(0); // 5×0×0=0

      // Simple motorized: minimal everything
      await market.connect(alice).createDesign(
        "Simple Motor", "Qm2", "one motor spin", 2, 1, 1, hash,
        { value: CREATE_FEE }
      );
      expect((await market.designs(2)).complexityScore).to.equal(2); // 2×1×1=2

      // Complex robot: high everything
      await market.connect(alice).createDesign(
        "Hexapod", "Qm3", "six-legged walker", 15, 5, 5, hash,
        { value: CREATE_FEE }
      );
      expect((await market.designs(3)).complexityScore).to.equal(375); // 15×5×5=375
    });
  });

  describe("Analytics", function () {
    it("should track total paid and royalties", async function () {
      const hash = ethers.keccak256(ethers.toUtf8Bytes("test"));
      
      await market.connect(alice).createDesign(
        "Design A", "Qm1", "test", 3, 1, 1, hash,
        { value: CREATE_FEE }
      );

      await market.connect(bob).forkDesign(
        1, "Design B", "Qm2", "fork test", 4, 2, 1, hash,
        { value: FORK_FEE }
      );

      const totalPaid = await market.totalPaid();
      expect(totalPaid).to.equal(CREATE_FEE + FORK_FEE);

      const totalRoyalties = await market.totalRoyaltiesPaid();
      expect(totalRoyalties).to.be.gt(0);
    });
  });
});
