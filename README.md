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

---

### 10. 🔐 Set the Webhook Secret  

You don’t need to manually create or configure any secret token — the setup script takes care of it for you.  

It will automatically:

- 🔐 Generate a secure token
- ✅ Add it to your Vercel environment as `SECRET_API_TOKEN`
- ✅ Configure your DatoCMS project:
  - Webhook: **Invalidate Next.js Cache**
  - Plugins:
    - `datocms-plugin-web-previews`
    - `datocms-plugin-seo-readability-analysis`

> 🧠 Want to handle this manually instead?
>
> You can generate your own token like this:
>
> ```bash
> openssl rand -hex 32
> ```
> Then follow the manual setup instructions below to apply it yourself.

---

### 11. 🔧 Final Setup: Configure Vercel Environment Variables & Redeploy  

We’ve bundled everything — secure token, environment variables, plugin + webhook config, GitHub Actions restore, and redeployment — into a single script:

---

### 🪄 One-liner setup

#### 1. 🛠 Install the Vercel CLI (if not already installed)

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

#### 2. ▶️ Run the init script

From the root of your cloned repo:

```bash
chmod +x ./scripts/init-project.sh
./scripts/init-project.sh
```

This will:

- 🔐 **Generate a secure token**
- 🌐 Detect your latest production deployment
- 🔧 Set the `SITE_URL` and `SECRET_API_TOKEN` env vars on Vercel
- 🔄 Update:
  - ✅ Your **webhook URL** (Invalidate Next.js Cache)
  - ✅ `datocms-plugin-web-previews`
  - ✅ `datocms-plugin-seo-readability-analysis`
- 🛠 Restore `.github/workflows/`
- 🚀 Redeploy your project to production
- 🧹 Delete itself after running

---

### ⏳ What happens next?

After the script completes:

- 🔁 Your `README.md` will be updated with the **next steps of the project**
- 🧭 This update is automatic and only takes a few seconds

> 🕒 **Please wait ~30 seconds**, then **refresh your GitHub repository page** to see the updated README.

---

### 📝 Prefer Manual Setup?

You can still configure everything manually if needed:

---

#### 1. Set environment variables via Vercel UI:

Go to [https://vercel.com/dashboard](https://vercel.com/dashboard), select your project → **Settings** → **Environment Variables**, and add:

| Key               | Value                                 |
|------------------|---------------------------------------|
| `SECRET_API_TOKEN` | The token you generated manually      |
| `SITE_URL`         | Your deployed domain (e.g. `https://example.com`) |

> ⚠️ Do not include a trailing slash in `SITE_URL`.

---

#### 2. Manually configure Webhooks and Plugins in DatoCMS:

- 🔁 **Webhook**:
  - Go to **Settings → Webhooks**
  - Edit the "Invalidate Next.js Cache" webhook
  - Set the URL to:  
    `https://your-vercel-domain/api/invalidate-cache?token=YOUR_SECRET`

- 🧩 **Plugin Configs**:
  - Go to **Settings → Plugins** → `datocms-plugin-web-previews`
    - Set preview webhook to:  
      `https://your-vercel-domain/api/preview-links?token=YOUR_SECRET`
  - Then update `datocms-plugin-seo-readability-analysis`:
    - Set Frontend metadata endpoint URL to:  
      `https://your-vercel-domain/api/seo-analysis?token=YOUR_SECRET`
    - Set Auto-apply to all JSON fields with the following API identifier: to:
      - `seo_analysis`

---

#### 3. Restore GitHub Actions manually:

```bash
mv .github/_workflows .github/workflows
rm -rf .github/_workflows
git add .github/workflows
git add .github/_workflows
git commit -m "Restore GitHub Actions workflows"
git push
```

> 🕒 After pushing, wait ~30 seconds and refresh the repo page — a GitHub Action will update the README with the next steps.

---

#### 4. Redeploy manually:

Via CLI:

```bash
vercel --prod
```

Or via the **Vercel UI**:

- Go to [https://vercel.com/dashboard](https://vercel.com/dashboard)
- Open your project
- Click **"Deployments"** → **"+" (top right)** → **"Create deployment"**

---

Once complete, your project is fully configured and deployed!  

🕒 **Hang tight — it may take around 30 seconds for everything to finalize.**  
🔁 When ready, **refresh this page** to see the next steps.

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

If the automatic GitHub Action fails to initialize the repository, you can complete the setup manually using the GitHub web interface and local Git.

---

### 1. Add Repository Secrets in GitHub

1. Go to your GitHub repository.
2. Navigate to **Settings → Secrets and variables → Actions**.
3. Click **“New repository secret”** and add the following:

| Name                             | Value |
|----------------------------------|--------|
| DATOCMS_PUBLISHED_CONTENT_CDA_TOKEN | From DatoCMS |
| DATOCMS_DRAFT_CONTENT_CDA_TOKEN     | From DatoCMS |
| DATOCMS_CMA_TOKEN                   | From DatoCMS |
| SECRET_API_TOKEN                    | A secure token you define |
| SITE_URL                            | e.g. https://your-site.vercel.app |
| LHCI_GITHUB_APP_TOKEN *(optional)*  | From [Lighthouse CI GitHub App](https://github.com/apps/lighthouse-ci) |

Repeat the process under **Settings → Secrets and variables → Dependabot**.

---

### 2. Enable GitHub Pages (using GitHub UI only)

1. Go to your repository’s **Code** tab.
2. Click the branch selector (top-left, usually says `main`).
3. Type `gh-pages` and click **"Create branch: gh-pages from 'main'"**.
4. Go to **Settings → Pages**.
5. Under **Pages**, set:
   - **Source**: `Deploy from a branch`
   - **Branch**: `gh-pages`
   - **Folder**: `/ (root)`
6. Click **Save**.

---

### 3. Configure Repository Settings

Go to your repository’s **Code** tab.

- On the right, on **About**: Set the Website to your deployed site (e.g. `https://your-site.vercel.app`)

Go to your repository’s **Settings → General → Features** tab.

- Disable **Projects**
- Disable **Wiki**

Then go to **Settings → General → Pull Requests** and configure:

- Disable **Allow merge commits**
- Disable **Allow rebase merging**
- Enable **Allow squash merging**
  - **Default commit message**: Pull request title and description
- Enable **Automatically delete head branches**

---

### 4. Clean Up Initialization Files Locally

Once everything is working, remove the setup-related files locally and push the changes:

```bash
git rm -r \
  .github/workflows/init-repo.yml \
  .github/workflows/reveal-clone-repo-readme.yml \
  scripts/initialize-repo.sh \
  scripts/init-project.sh \
  datocms.json \
  src/app/api/post-deploy

git commit -m "chore: remove repository initialization files"
git push
```

---

### 5. Clean Up the README

Manually open `README.md` and:

- Delete everything between:
  &lt;!-- INIT-REPO-START --&gt; and &lt;!-- INIT-REPO-END --&gt;
- Delete everything between:
  &lt;!-- REPO-CLONED-START --&gt; and &lt;!-- REPO-CLONED-END --&gt;
- Remove the two lines used to comment out the original README:
  - &lt;!-- ORIGINAL-README-START
  - ORIGINAL-README-END --&gt;
- Replace **[__PROJECT_TITLE__]** by your project title
- Replace **https://your-datocms-project.admin.datocms.com** by your DatoCMS project admin dashboard URL
- Replace **https://your-storybook-url.com** by your Github Pages URL, you can find it under **Settings → Pages**

```bash
git add README.md
git commit -m "docs: clean up readme after manual setup"
git push
```

---

Once complete, your repository is fully configured and ready for development.
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
