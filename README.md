<!-- INIT-REPO-START -->
## 🚀 Quick Start Guide

Follow these steps to launch your DatoCMS + Vercel + GitHub-powered project in minutes:

---

### 1. 🏗️ Create a DatoCMS Organization  

If you don’t have one already, [create a DatoCMS organization](https://dashboard.datocms.com) for your project.

---

### 2. ⚡ Deploy via DatoCMS Setup Wizard  

Click the button below to launch the setup flow:

[![Deploy with DatoCMS](https://dashboard.datocms.com/deploy/button.svg)](https://dashboard.datocms.com/deploy?repo=Androlax2%2Ftheo-nextjs-dato-starter%3Amain)

✅ This will:
- Clone the GitHub repo
- Create the DatoCMS project
- Link it all together

---

### 3. ⏳ Select Your Organization  
After a few seconds, the dropdown should populate with your DatoCMS organizations:

<img width="1023"  alt="Organization dropdown" src="https://github.com/user-attachments/assets/e8c5255d-dfb3-4d89-bd06-2f8aad04afc4" />

---

### 4. 🧱 Name and Create the Project  
Give your new project a name, then click **Create Project**.

---

### 5. 🌐 Link a Website  
Click **"Wait, I also want a website to be linked to the project!"**

<img width="1056" alt="Link website" src="https://github.com/user-attachments/assets/df09b2c9-dee3-423e-9060-8554d69502fa" />

---

### 6. ☁️ Choose Vercel  
Select **Vercel** as your deployment target.

<img width="965" alt="Screenshot 2025-03-27 at 19 06 16" src="https://github.com/user-attachments/assets/55b29b19-2ed7-4125-bbc4-bb494a25f40f" />

---

### 7. 🔗 Connect GitHub  
On the next screen, choose **GitHub** as your Git provider:

<img width="1152" alt="Connect GitHub" src="https://github.com/user-attachments/assets/c578a79d-4be1-474f-8d75-a97712fae8b7" />

---

### 8. 🚀 Deploy the Project  

Follow the Vercel Wizard and deploy the project.

---

### 9. 💻 Clone Your New Repository

Once the setup wizard finishes, it will have created a new GitHub repository under your account or organization.

Clone it locally:

<!-- code block -->
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
cd YOUR_REPO_NAME
<!-- code block -->

> Replace `YOUR_USERNAME/YOUR_REPO_NAME` with the actual path to your newly created GitHub repo.

---

### 10. 🔐 Set the Webhook Secret  

Generate a secure token:

```bash
openssl rand -hex 32
```

Copy the result and replace `secretTokenProtectingWebhookEndpointsFromBeingCalledByAnyone` in:

- ✅ **Project Settings → Webhooks** (Invalidate Next.js Cache)
- ✅ **Configuration → Plugins** (2 plugin configs)

---

### 11. 🔧 Configure Vercel Environment Variables  

## 📝 Manually

Set the following in your Vercel project settings:

| Key               | Value                                 |
|------------------|---------------------------------------|
| `SECRET_API_TOKEN` | The token you generated above         |
| `SITE_URL`         | Your deployed domain (e.g. `https://example.com`) |

> ⚠️ Do not include a trailing slash in `SITE_URL`.

---

## 🔁 Automatically (with Vercel CLI)

You can also configure your environment variables from the command line:

### 1. 🛠 Install the Vercel CLI

```bash
npm i -g vercel
```

Or with `pnpm` / `yarn`:

```bash
pnpm i -g vercel
# or
yarn global add vercel
```

---

### 2. 🔗 Link Your Project

If your project isn’t already linked to Vercel:

```bash
vercel link
```

This will prompt you to select your team, project, and confirm the setup.

---

### 3. 🌐 Set `SITE_URL` Automatically

Fetch the latest production deployment and use it to set `SITE_URL`:

```bash
DEPLOYMENT_URL=$(vercel ls --prod | grep -m1 -Eo 'https://[a-z0-9\-]+\.vercel\.app')

PROJECT_NAME=$(echo "$DEPLOYMENT_URL" | sed -E 's|https://([a-z0-9\-]+)-[a-z0-9]+-[a-z0-9]+\.vercel\.app|\1|')
[ -z "$PROJECT_NAME" ] && PROJECT_NAME=$(basename "$DEPLOYMENT_URL" | cut -d. -f1)

SITE_URL="https://${PROJECT_NAME}.vercel.app"
echo "Detected domain: $SITE_URL"

echo "$SITE_URL" | vercel env add SITE_URL production
```

---

### 4. 🔐 Add Your Secret API Token

Paste your secret token into Vercel like this:

```bash
vercel env rm SECRET_API_TOKEN --yes
echo "your-secret-token-here" | vercel env add SECRET_API_TOKEN production
```

> ⚠️ Replace "your-secret-token-here" with the actual token you generated earlier.

---

Now your production environment will have both `SITE_URL` and `SECRET_API_TOKEN` correctly set!

---

### 12. 🔄 Redeploy the Project  

After setting env vars, trigger a new deployment on Vercel.

---

### 13. 💻 Restore GitHub Actions Workflows

Run the following commands to restore the GitHub Actions workflows:

```bash
mv .github/_workflows .github/workflows
git add .github/workflows
git commit -m "Restore GitHub Actions workflows"
git push
```

> This ensures that the workflows are correctly committed to your repository.  
> For some reason, Vercel removes the `./github/workflows/` folder when cloning.

Once that’s done, you're all set! The `README.md` will automatically update to show you the next steps.

---
<!-- INIT-REPO-END -->

<!-- REPO-CLONED-START
## ✅ You're Almost Ready!

Now that you've cloned this repository, follow these steps to finish the setup:

---

### 🌱 1. Set Up Environment Variables

Copy the example `.env` file into a working one:

```bash
cp .env.local.example .env.local
```

Then in your [DatoCMS project](https://dashboard.datocms.com):

1. Go to **Settings → API tokens**
2. Copy and paste the following values into your `.env.local` file:

| Variable                             | Source / Description            |
|--------------------------------------|---------------------------------|
| `DATOCMS_PUBLISHED_CONTENT_CDA_TOKEN` | DatoCMS – CDA Only (Published)  |
| `DATOCMS_DRAFT_CONTENT_CDA_TOKEN`     | DatoCMS – CDA Only (Draft)      |
| `DATOCMS_CMA_TOKEN`                   | DatoCMS – CMA Only (Admin)      |
| `SECRET_API_TOKEN`                    | Value generated earlier         |

Make sure your `.env.local` contains all of the above before proceeding.

---

### 🔐 2. Create a GitHub Personal Access Token (PAT)

Go to [https://github.com/settings/personal-access-tokens](https://github.com/settings/personal-access-tokens)  
→ Click **“Generate new token (classic)”** or create a **fine-grained token**

> **Scope: Read & Write access**

Enable these permissions:

#### 🔧 Repository permissions:
- ✅ **Administration**
- ✅ **Dependabot secrets**
- ✅ **Environments**
- ✅ **Pages**
- ✅ **Secrets**

📌 Save this token securely — you’ll use it during repository initialization.

---

### 📊 3. (Optional) Set Up Lighthouse CI

> 🧪 This step is **optional** — only needed if you want to enable Lighthouse CI reports in GitHub Actions.

1. Visit [https://github.com/apps/lighthouse-ci](https://github.com/apps/lighthouse-ci)
2. Click on **Configure**
3. Choose the repo you just cloned
4. Copy the **project token**

📌 Save this token — it will be used during the next step if you enable Lighthouse CI.

---

### ⚙️ 4. Initialize the Repository

Open the **Actions** tab in this GitHub repo, then:

- Find the **`Initialize Repo`** workflow on the left
- Click **“Run workflow”** on the right side
- Fill in the inputs:
  - 🧪 Paste your full `.env.local` content
  - 🔑 Your GitHub Personal Access Token
  - 🌐 Your deployed Vercel site URL (e.g. `https://your-site.vercel.app`)
  - 📊 _(Optional)_ Your Lighthouse CI App token

> 🕐 After clicking Run, wait until the GitHub Action completes successfully.
> You’ll see your repository auto-configure itself (secrets, README, GitHub Pages, etc.).

Once it’s done, you’re ready to work with the repo as usual! ✅

---

### 🛟 5. If Initialization Fails...

No worries — you can still access the full documentation manually.

Open `README.md` and look for:

```html
<!-- ORIGINAL-README-START  
...
ORIGINAL-README-END --\>
```

Delete those two comment lines to reveal the full project documentation.

---
REPO-CLONED-END -->

<!-- ORIGINAL-README-START
# [__PROJECT_TITLE__]

## Summary

- [Local Setup](#local-setup)
    - [Set up environment variables](#set-up-environment-variables)
    - [Run your project locally](#run-your-project-locally)
- [VS Code](#vs-code)
- [Tailwind IntelliSense](#tailwind-intellisense)
    - [VS Code](#tailwind-intellisense-vs-code)
    - [JetBrains](#tailwind-intellisense-jetbrains)
- [Updating the GraphQL Schema](#updating-the-graphql-schema)
- [Storybook](#storybook)
  - [Local Storybook](#local-storybook)
  - [GitHub Pages Storybook](#github-pages-storybook)
- [Component Generation](#component-generation)
- [Block Generation](#block-generation)

---

### Local setup

#### Set up environment variables

Copy the sample .env file:

```bash
cp .env.local.example .env.local
```

In your [DatoCMS project dashboard](https://your-datocms-project.admin.datocms.com), go to the **Settings** menu at the top and click **API tokens**.

Copy the values of the following tokens into the specified environment variable:

- `DATOCMS_PUBLISHED_CONTENT_CDA_TOKEN`: CDA Only (Published)
- `DATOCMS_DRAFT_CONTENT_CDA_TOKEN`: CDA Only (Draft)
- `DATOCMS_CMA_TOKEN`: CMA Only (Admin)

Then set `SECRET_API_TOKEN` as a secure string (you can use `openssl rand -hex 32` or any other cryptographically-secure random string generator). It will be used to safeguard all route handlers from incoming requests from untrusted sources.

#### Run your project locally

```bash
npm install
npm run dev
```

Your website should be up and running on [http://localhost:3000](http://localhost:3000)!

## VS Code

It is highly recommended to follow [these instructions](https://gql-tada.0no.co/get-started/installation#vscode-setup) for an optimal experience with Visual Studio Code, including features like diagnostics, auto-completions, and type hovers for GraphQL.

## Tailwind IntelliSense

This project uses Tailwind CSS for styling. To enable IntelliSense for Tailwind CSS classes in your editor, you can install the following extensions:

## Tailwind IntelliSense VS Code

1. [Install the "Tailwind CSS IntelliSense" Visual Studio Code extension](https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss)
2. Add the following to your [settings.json](https://code.visualstudio.com/docs/configure/settings):

```json
{
  "tailwindCSS.experimental.classRegex": [
    ["cva\\(((?:[^()]|\\([^()]*\\))*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"],
    ["cx\\(((?:[^()]|\\([^()]*\\))*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)"],
    ["@tw\\s\\*\/\\s+[\"'`]([^\"'`]*)"]
  ]
}
```

## Tailwind IntelliSense JetBrains

1. Open the settings. Go to [Languages and Frameworks | Style Sheets | Tailwind CSS](https://www.jetbrains.com/help/webstorm/tailwind-css.html#ws_css_tailwind_configuration)
2. Add the following to your tailwind configuration

```json
{
  "experimental": {
    "classRegex": [
      ["cva\\(((?:[^()]|\\([^()]*\\))*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"],
      ["cx\\(((?:[^()]|\\([^()]*\\))*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)"],
      ["@tw\\s\\*\/\\s+[\"'`]([^\"'`]*)"]
    ]
  }
```

## Updating the GraphQL schema

When the DatoCMS schema, which includes various models and fields, undergoes any updates or modifications, it is essential to ensure that these changes are properly reflected in your local development environment. To accomplish this, you should locally run the following command:

```
npm run generate-schema
```

Executing this task will automatically update the `schema.graphql` file for you. This crucial step ensures that gql.tada will have access to the most current and accurate version of the GraphQL schema, allowing your application to function correctly with the latest data structures and relationships defined within your DatoCMS setup.

**⚠️ Sometimes, there will be a little time before Typescript works again with the changes and GraphQL, If you encounter issues with that (field marked as not here but they should be there for instance). Restart your Typescript server. (Look on Google to do it for VSCode, JetBrains, ...) ⚠️**

## Storybook

### Local Storybook

To run Storybook locally, execute the following command:

```bash
npm run storybook
```

This will start Storybook on [http://localhost:6006](http://localhost:6006) where you can view and interact with your component library.

### GitHub Pages Storybook

You can [📚 View Storybook](https://your-storybook-url.com) here.

## Component Generation

To generate a new component, run the following command:

```bash
npm run generate:component
```

This command creates a new folder under `src/components` containing:

- `ComponentName.tsx` – The component file.
- `ComponentName.stories.tsx` – The Storybook file.
- `ComponentName.test.tsx` – The test file.

Simply modify the generated files to implement your component.

## Block Generation

Blocks are used for CMS content that typically comes with [colocated GraphQL fragments](https://gql-tada.0no.co/guides/fragment-colocation). To generate a new block, run the following command:

```bash
npm run generate:block
```

This command creates a new folder under `src/components/blocks` containing:

- `BlockName.tsx` – The block file.

Simply modify the generated file to implement your block.

➡️ Let the command finish, do not stop it, it'll run `npm run generate-schema` after a block creation.

**⚠️ Sometimes, there will be a little time before Typescript works again with the changes and GraphQL, If you encounter issues with that (field marked as not here but they should be there for instance). Restart your Typescript server. (Look on Google to do it for VSCode, JetBrains, ...) ⚠️**
ORIGINAL-README-END -->
