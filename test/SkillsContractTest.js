const SkilleX = artifacts.require("SkilleX.sol");
const KittyNFT = artifacts.require("KittyNFT.sol");
const ERC721ComposableRegistry = artifacts.require("ERC721ComposableRegistry.sol");

contract('SkilleX', (accounts) => {

    beforeEach(async () => {
        this.composableRegistry = await ERC721ComposableRegistry.new();
        this.skills = await SkilleX.new(this.composableRegistry.address);
        this.kitties = await KittyNFT.new();
        await this.kitties.create();
    });

	it("should allow to create skill", async () => {
		await this.skills.createSkill("Name", "ipfs hash", this.kitties.address, 1);
		const ownerOfSkill = await this.composableRegistry.ownerOf(this.skills.address, 1);
		assert.equal(ownerOfSkill, accounts[0]);
	});

	it("should not allow skill transferring", async () => {
		await this.skills.createSkill("Name", "ipfs hash", this.kitties.address, 1);
        try {
            await this.composableRegistry.transferToAddress(accounts[0], this.skills.address, 1);
            assert.fail();
        } catch (ex) {
            if (ex.name == 'AssertionError') throw ex;
        }
	});

	it("should learn skill from teacher", async () => {
		await this.skills.createSkill("Name", "ipfs hash", this.kitties.address, 1);
        await this.kitties.create();
        await this.skills.offerTeach(1, 100);
        const kitty2SkillState = await this.skills.hasSkill(this.kitties.address, 2, "ipfs hash")
        assert.equal(kitty2SkillState, false)
        await this.skills.learn(0, this.kitties.address, 2, {value: '100'})
        const kitty2NewSkillState = await this.skills.hasSkill(this.kitties.address, 2, "ipfs hash")
        assert.equal(kitty2NewSkillState, true)
	});
});
