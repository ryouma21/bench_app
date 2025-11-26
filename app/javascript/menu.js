document.addEventListener("DOMContentLoaded", () => {

  const menus = [
    {main: "ベンチプレス 75kg × 5回 × 4セット", sub: "休憩：2〜3分 / RPE：8", adv: "肩をすくめず胸を張る意識。"},
    {main: "ベンチプレス 70kg × 8回 × 3セット", sub: "フォーム重視", adv: "ゆっくり下ろして丁寧に上げる。"},
    {main: "ベンチプレス 80kg × 3回 × 5セット", sub: "重めの日", adv: "足で床を強く踏んで安定させる。"}
  ];

  let idx = 0;

  const changeBtn = document.getElementById("change-btn");
  const startBtn  = document.getElementById("start-btn");

  function changeMenu() {
    idx = (idx + 1) % menus.length;
    document.getElementById("menu-main").textContent = menus[idx].main;
    document.getElementById("menu-sub").textContent  = menus[idx].sub;
    document.getElementById("advice").textContent    = menus[idx].adv;
  }
    // ✅ 別のメニューを見るボタン
  if (changeBtn) {
    changeBtn.addEventListener("click", changeMenu);
  }

  // ✅ 開始ボタン
  if (startBtn) {
    startBtn.addEventListener("click", () => {
      alert("トレーニング開始！");
    });
  }
});
