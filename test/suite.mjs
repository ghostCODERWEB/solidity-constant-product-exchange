export async function suite(h) {
  const t0 = await h.token();
  const t1 = await h.token();
  const c = await h.deploy("ProductPool", [
    t0.target,
    t1.target,
    30,
    h.addresses[0],
  ]);
  await h.tx(t0.approve(c.target, 100000000));
  await h.tx(t1.approve(c.target, 100000000));
  await h.test("initial liquidity locks minimum shares", async () => {
    await h.tx(c.addLiquidity(1000000, 1000000, 1));
    h.eq(
      await c.balanceOf("0x000000000000000000000000000000000000dEaD"),
      1000n,
    );
  });
  await h.test("slippage rejects excessive minimum", () =>
    h.revert(() => c.swap(t0.target, 10000, 999999)),
  );
  await h.test("swap retains fees in invariant", async () => {
    const before = (await c.reserve0()) * (await c.reserve1());
    await h.tx(c.swap(t0.target, 10000, 1));
    h.ok((await c.reserve0()) * (await c.reserve1()) >= before);
  });
  await h.test("invalid input asset rejected", () =>
    h.revert(() => c.quote(h.addresses[1], 100)),
  );
  await h.test("LP shares redeem proportional reserves", async () => {
    await h.tx(c.removeLiquidity(10000, 1, 1));
    h.eq(await c.totalSupply(), 990000n);
  });
  await h.test("pause blocks swaps but permits exits", async () => {
    await h.tx(c.setPaused(true));
    await h.revert(() => c.swap(t0.target, 100, 1));
    await h.tx(c.removeLiquidity(1000, 1, 1));
  });
}
