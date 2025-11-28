document.addEventListener("turbo:load", () => {

  // ホーム画面にしか無い要素を取得
  const changeBtn = document.getElementById("change-btn");
  const menuMain  = document.getElementById("menu-main");
  const menuSub   = document.getElementById("menu-sub");
  const adviceEl  = document.getElementById("advice");

  // ホーム画面に必要な要素が全部揃っているか？
  if (!changeBtn || !menuMain || !menuSub || !adviceEl) {
    return; // ← JS を止める（他のページでは何もしない）
  }

  // メニューのデータ
  const menus = [
    {main: "ベンチプレス 75kg × 5回 × 4セット", sub: "休憩：2〜3分 / RPE：8", adv: "肩をすくめず胸を張る意識。"},
    {main: "ベンチプレス 70kg × 8回 × 3セット", sub: "フォーム重視", adv: "ゆっくり下ろして丁寧に上げる。"},
    {main: "ベンチプレス 80kg × 3回 × 5セット", sub: "重めの日", adv: "足で床を強く踏んで安定させる。"}
  ];

  let idx = 0;

  // メニュー切替関数
  function changeMenu() {
    idx = (idx + 1) % menus.length;
    menuMain.textContent = menus[idx].main;
    menuSub.textContent  = menus[idx].sub;
    adviceEl.textContent = menus[idx].adv;
  }

  // 別メニューを見るボタン
  changeBtn.addEventListener("click", changeMenu);

});
