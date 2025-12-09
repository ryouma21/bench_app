document.addEventListener("turbo:load", () => {

  // ① 必要な要素を取ってくる
  const changeBtn       = document.getElementById("change-btn");
  const altMenuBtnArea  = document.getElementById("alt-menu-buttons");
  const lighterBtn      = document.getElementById("lighter-btn");
  const heavierBtn      = document.getElementById("heavier-btn");
  const menuMain        = document.getElementById("menu-main");
  const recordBtn = document.getElementById("record-btn");
  const menuHint        = document.getElementById("menu-hint");

  // もしホーム画面じゃなかったら何もしない安全策
  if (!changeBtn || !altMenuBtnArea  || !menuMain)
    return; // ← JS を止める（他のページでは何もしない）

  // 「他のメニューを提案」を押したら2つのボタンを表示するだけ
  changeBtn.addEventListener("click", () => {
    changeBtn.style.display = "none";       // 元のボタンは隠す
    altMenuBtnArea.style.display = "block"; // 軽め/重めボタンを見せる

    if (menuHint) menuHint.style.display = "none";
  });

  // 「フォーム重視でやる」押したとき → 軽めメニューをRailsからfetch
  lighterBtn.addEventListener("click", () => {
    fetch("/menus/lighter")
      .then(res => res.json())
      .then(data => {
        menuMain.textContent =
          `ベンチプレス ${data.weight}kg × ${data.reps}回 × ${data.sets}セット`;

        // 記録ボタンのURLを更新
        recordBtn.href =
          `/training_records/new?weight=${data.weight}&reps=${data.reps}&sets=${data.sets}`;
      });
  });

  // 「刺激を入れてみる」押したとき → 重めメニューをRailsからfetch
  heavierBtn.addEventListener("click", () => {
    fetch("/menus/heavier")
      .then(res => res.json())
      .then(data => {
        menuMain.textContent =
          `ベンチプレス ${data.weight}kg × ${data.reps}回 × ${data.sets}セット`;
        
        recordBtn.href =
        `/training_records/new?weight=${data.weight}&reps=${data.reps}&sets=${data.sets}`;
      });
  });
});
