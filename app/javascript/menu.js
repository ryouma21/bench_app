document.addEventListener("turbo:load", () => {

  const menus = [
    {main: "ベンチプレス 75kg × 5回 × 4セット", sub: "休憩：2〜3分 / RPE：8", adv: "肩をすくめず胸を張る意識。"},
    {main: "ベンチプレス 70kg × 8回 × 3セット", sub: "フォーム重視", adv: "ゆっくり下ろして丁寧に上げる。"},
    {main: "ベンチプレス 80kg × 3回 × 5セット", sub: "重めの日", adv: "足で床を強く踏んで安定させる。"}
  ];

  let idx = 0;

  const changeBtn = document.getElementById("change-btn");
  const startBtn  = document.getElementById("start-btn");

  if (changeBtn) {
    changeBtn.onclick = () => {
      idx = (idx + 1) % menus.length;
      document.getElementById("menu-main").textContent = menus[idx].main;
      document.getElementById("menu-sub").textContent  = menus[idx].sub;
      document.getElementById("advice").textContent    = menus[idx].adv;
    };
  }

  if (startBtn) {
    startBtn.onclick = () => alert("トレーニング開始！");
  }

});
