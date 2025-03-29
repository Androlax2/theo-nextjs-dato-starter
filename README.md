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

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
cd YOUR_REPO_NAME
```

> Replace `YOUR_USERNAME/YOUR_REPO_NAME` with the actual path to your newly created GitHub repo.

> ✅ Now that your project is ready, you can close this tab and open the **README in your newly cloned repository**.  
> Continue directly from **step 10** — the instructions pick up right there.

---

### 10. ▶️ Run the `init-project.sh` script

From the root of your cloned repo:

```bash
chmod +x ./scripts/init-project.sh
./scripts/init-project.sh
```

This script will automate your entire setup in just a few minutes.

> 💡 Prefer to do things manually?
> 
> No problem! You can skip the script and follow the detailed instructions in Step 11. 📝 Prefer Manual Setup?.
> 
> This is a great option if you want full control or you’re working in a restricted environment (e.g. no GitHub PAT).

---

### 11. 📝 Prefer Manual Setup?

If you prefer not to run the `init-project.sh` script, you can follow the steps below to manually configure your **Vercel + GitHub + DatoCMS** project.

---

## 🧩 Part 1 — DatoCMS Configuration

---

### 1. 🌐 Configure Project on Vercel

- Open [https://vercel.com/dashboard](https://vercel.com/dashboard)
- Create or select your project
- Connect your GitHub repository (if not already)
- Deploy your site
- Copy your deployed URL (e.g. `https://your-project.vercel.app`)

---

### 2. 🔐 Generate a Secret API Token

Generate a secure token using:

```bash
openssl rand -hex 32
```

- Copy the generated token
- This will be your `SECRET_API_TOKEN`

---

### 3. 📁 Create `.env.local` File

Copy the example environment file:

```bash
cp .env.local.example .env.local
```

Go to your [DatoCMS dashboard](https://your-datocms-project.admin.datocms.com):

- Navigate to **Project Settings → API tokens**
- Copy the following tokens and paste them into your `.env.local` file:

| Variable                              | Source                      |
|---------------------------------------|-----------------------------|
| `DATOCMS_PUBLISHED_CONTENT_CDA_TOKEN` | CDA Only (Published)        |
| `DATOCMS_DRAFT_CONTENT_CDA_TOKEN`     | CDA Only (Draft)            |
| `DATOCMS_CMA_TOKEN`                   | CMA Only (Admin)            |
| `SECRET_API_TOKEN`                    | Your generated secret token |

---

### 4. ☁️ Set Vercel Environment Variables (via UI)

1. Open [https://vercel.com/dashboard](https://vercel.com/dashboard)
2. Select your project
3. Go to **Settings → Environment Variables**
4. Add the following variables:

| **Key**                                | **Value**                                                      |
|----------------------------------------|----------------------------------------------------------------|
| `SITE_URL`                             | Your deployed site URL (e.g. `https://your-project.vercel.app`) |
| `SECRET_API_TOKEN`                     | The secure token you generated                                |
| `DATOCMS_PUBLISHED_CONTENT_CDA_TOKEN`  | From DatoCMS → CDA Only (Published)                           |
| `DATOCMS_DRAFT_CONTENT_CDA_TOKEN`      | From DatoCMS → CDA Only (Draft)                               |
| `DATOCMS_CMA_TOKEN`                    | From DatoCMS → CMA Only (Admin)                               |

> 💡 Make sure you **do not include a trailing slash** in `SITE_URL`.

---

### 5. 🔁 Configure Webhook in DatoCMS

In your DatoCMS project:

- Go to **Settings → Webhooks**
- Create or edit a webhook with the following settings:

| Field     | Value                                                                 |
|-----------|-----------------------------------------------------------------------|
| **Name**  | Invalidate Next.js Cache                                              |
| **URL**   | `https://your-project.vercel.app/api/invalidate-cache?token=YOUR_SECRET` |

---

### 6. 🧩 Install and Configure Plugins in DatoCMS

#### A. Web Previews Plugin

- Install `datocms-plugin-web-previews` or update the existing one
- Set **Preview URL** to:

```bash
https://your-project.vercel.app/api/preview-links?token=YOUR_SECRET
```

---

#### B. SEO Analysis Plugin

- Install `datocms-plugin-seo-readability-analysis` or update the existing one
- Set **Frontend metadata endpoint** to:

```bash
https://your-project.vercel.app/api/seo-analysis?token=YOUR_SECRET
```

- Enable **Auto-apply to fields with API key**: `seo_analysis`

---

#### C. Slug With Collections Plugin

- Install `datocms-plugin-slug-with-collections` or update the existing one
- Go to **API Tokens**
- Use a **Read-only API token**
- Configure the plugin with this token in its settings

---

## 🛠️ Part 2 — GitHub Repository Configuration

---

### 7. 🔁 Restore GitHub Actions

If `.github/_workflows` exists, run:

```bash
mv .github/_workflows .github/workflows
rm -rf .github/_workflows
git add .github/workflows
git rm -r --cached .github/_workflows
git commit -m "Restore GitHub Actions workflows" --no-verify
git push --no-verify
```

---

### 8. ⚙️ Configure Repository Settings (via GitHub UI)

1. Go to your repository on GitHub
2. Click **Settings → General**

#### General Settings:

- ✅ Enable **Squash merging**
- 🚫 Disable **Merge commits**
- 🚫 Disable **Rebase merging**
- ✅ Enable **Automatically delete head branches**
- ✅ Enable **Issues**
- 🚫 Disable **Projects** (unless needed)
- 🚫 Disable **Wikis**
- Set **Project homepage** to your deployed URL (e.g. `https://your-project.vercel.app`)

---

### 9. 🔐 Add GitHub Secrets (for Actions & Dependabot)

Go to **Settings → Secrets and variables**:

- Under both **Actions** _and_ **Dependabot**, add the following secrets:

| Name                                 | Value                                       |
|--------------------------------------|---------------------------------------------|
| `DATOCMS_PUBLISHED_CONTENT_CDA_TOKEN`| From DatoCMS: CDA Only (Published)          |
| `DATOCMS_DRAFT_CONTENT_CDA_TOKEN`    | From DatoCMS: CDA Only (Draft)              |
| `DATOCMS_CMA_TOKEN`                  | From DatoCMS: CMA Only (Admin)              |
| `SITE_URL`                           | Your deployed Vercel URL                    |
| `SECRET_API_TOKEN`                   | The secure token you generated              |

> 🛡️ If you're using **Lighthouse CI**, also add `LHCI_GITHUB_APP_TOKEN` in both locations.

---

### 10. 🧽 Clean Up README.md

Open `README.md` and:

- Remove everything between:
    - `<!-- INIT-REPO-START -->` and `<!-- INIT-REPO-END -->`

- Replace placeholders:
    - `[__PROJECT_TITLE__]` → Your project title
    - `https://your-datocms-project.admin.datocms.com` → Your DatoCMS dashboard URL
    - `https://your-storybook-url.com` → Your GitHub Pages Storybook URL

- Remove the `<!-- ORIGINAL-README-START -->` and `<!-- ORIGINAL-README-END -->` comments

---

### 11. 🚀 Redeploy via Vercel

- Go to [https://vercel.com/dashboard](https://vercel.com/dashboard)
- Select your project → Go to **Deployments**
- Click **"Create Deployment"**

---

Your project is now **fully configured and deployed**! ✅
<!-- INIT-REPO-END -->

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
