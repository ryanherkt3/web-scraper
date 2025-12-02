const { webkit, chromium, firefox } = require('playwright');

const browserTypes = {
    'webkit': webkit,
    'chromium': chromium,
    'firefox': firefox,
};

const browserLaunchArgs = {
    'webkit': [],
    'chromium': [
        '--single-process',
    ],
    'firefox': [],
}

// getCustomExecutablePath = (expectedPath) => {
//     const suffix = expectedPath.split('/.cache/ms-playwright/')[1];
//     return  `/home/pwuser/.cache/ms-playwright/${suffix}`;
// }

async function scrape(url, browserName, extraLaunchArgs) {
    let browser = null;
    const data = [];
    
    try {
        browser = await browserTypes[browserName].launch({
            executablePath: browserTypes[browserName].executablePath(),
            args: browserLaunchArgs[browserName].concat(extraLaunchArgs),
        });
        const context = await browser.newContext();

        const page = await context.newPage();

        await page.goto(url);

        const title = await page.title();
        data.push(title);
    }
    catch (e) {
        console.error('Error with scraping script:', e);
    }
    finally {
        if (browser) {
            await browser.close();
        }
        return data;
    }
}

exports.handler = async (event, context) => {
    const browserName = event.browser || 'chromium';
    const extraLaunchArgs = event.browserArgs || [];
    
    try {
        console.log('Scraping started');
        const data = await scrape("https://google.com", browserName, extraLaunchArgs);
        console.log('Scraping finished');

        if (!data) {
            return {
                statusCode: 500,
                body: JSON.stringify({
                    success: false,
                }),
            };
        }

        return {
            statusCode: 200,
            body: data,
        };
    } catch (error) {
        console.error("error at index.js", error);

        return {
            statusCode: 500,
            body: JSON.stringify({
                error: error.message,
            }),
        };
    }
};