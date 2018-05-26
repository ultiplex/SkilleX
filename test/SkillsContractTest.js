const WithdraweX = artifacts.require("WithdraweX.sol");
const KittyNFT = artifacts.require("KittyNFT.sol");
const ERC721ComposableRegistry = artifacts.require("ERC721ComposableRegistry.sol");

contract('Skillex', (accounts) => {

    beforeEach(async () => {
        this.composableRegistry = await ERC721ComposableRegistry.new();
        this.skills = await WithdraweX.new(this.composableRegistry.address);
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
});
