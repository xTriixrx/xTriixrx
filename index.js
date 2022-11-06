const puppeteer = require('puppeteer');

function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto('https://ionicabizau.github.io/github-profile-languages/api.html?xTriixrx');
  await sleep(10000);
  await page.screenshot({ path: 'language-graph-light.png' });

  await page.addStyleTag({path: 'style.css'});
  await sleep(10000);
  await page.screenshot({path: `language-graph-dark.png` });

  await browser.close();
})();
