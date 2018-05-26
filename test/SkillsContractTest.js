const Skills = artifacts.require("Skills.sol");
const KittyNFT = artifacts.require("KittyNFT.sol");
const ERC721ComposableRegistry = artifacts.require("ERC721ComposableRegistry.sol");

contract('Skills', (accounts) => {

    beforeEach(async () => {
        this.composableRegistry = await ERC721ComposableRegistry.new();
        this.skills = await Skills.new(this.composableRegistry.address);
        this.kitties = await KittyNFT.new();
        await this.kitties.create();
    });

	it("should allow to create skill", async () => {
		await this.skills.createSkill("Name", "ipfs hash", formatToByteArray(this.kitties.address, 1));
		const ownerOfSkill = await this.composableRegistry.ownerOf(this.skills.address, 1);
		assert.equal(ownerOfSkill, accounts[0]);
	});
});


function formatToByteArray(toErc721, toTokenId) {
    return '0x' + toErc721.substring(2).padStart(64, '0') + toTokenId.toString().padStart(64, '0');
}