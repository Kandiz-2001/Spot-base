import { expect } from "chai";
import { ethers } from "hardhat";

describe("SpotBase", function () {
  it("should create a place and add a review", async () => {
    const [user] = await ethers.getSigners();
    const SpotBase = await ethers.getContractFactory("SpotBase");
    const c = await SpotBase.deploy();
    await c.deploymentTransaction()?.wait();

    const tx = await c.createPlace("Cafe", "Nice coffee", "12.34,56.78");
    const receipt = await tx.wait();
    const placeId = await c.nextPlaceId();
    expect(placeId).to.equal(1n);

    await expect(c.addReview(placeId, 5, "Great!"))
      .to.emit(c, "ReviewAdded")
      .withArgs(placeId, user.address, 5);

    const place = await c.getPlace(placeId);
    expect(place.name).to.equal("Cafe");
    expect(place.reviewCount).to.equal(1n);

    const reviews = await c.getReviews(placeId);
    expect(reviews.length).to.equal(1);
    expect(reviews[0].rating).to.equal(5);
  });

  it("should revert on invalid rating", async () => {
    const SpotBase = await ethers.getContractFactory("SpotBase");
    const c = await SpotBase.deploy();
    await c.deploymentTransaction()?.wait();

    await expect(c.addReview(1, 0, "bad")).to.be.revertedWithCustomError(c, "InvalidRating");
  });
});
