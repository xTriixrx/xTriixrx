const puppeteer = require('puppeteer');
const darkImage = `language-graph-dark.png`;
const lightImage = 'language-graph-light.png';
const profileLangPage = 'https://ionicabizau.github.io/github-profile-languages/api.html?xTriixrx';

function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  
  console.log("Going to Language Chart Page at: " + profileLangPage);
  
  await page.goto(profileLangPage);
  await sleep(10000);
  await page.screenshot({ path: lightImage });

  console.log("Screenshotted : " + lightImage);

  await sleep(10000);
  await page.screenshot({path: darkImage });

  console.log("Screenshotted : " + lightImage);
  
  await browser.close();

  const fs = require('fs');
  const data = "Testing pushing...";
  fs.writeFile('Test.txt', data, (err) => { if (err) throw err; });
})();
