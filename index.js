const FIVE_SEC = 5000;
const image = 'language-graph.png';
const { chromium } = require("playwright");
const profileLangPage = 'https://ionicabizau.github.io/github-profile-languages/api.html?xTriixrx';

function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

(async () => {
  let browser = await chromium.launch();
 
  let page = await browser.newPage();
  console.log("Viewing language page at: " + profileLangPage);

  await page.goto(profileLangPage);
  await page.setViewportSize({ width: 750, height: 750 });
  await sleep(FIVE_SEC);

  console.log("Creating Screenshot: " + image);
  
  await page.screenshot({ path: image });
  await browser.close();
})();