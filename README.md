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

---

### 7. 🔗 Connect GitHub  
On the next screen, choose **GitHub** as your Git provider:

<img width="1152" alt="Connect GitHub" src="https://github.com/user-attachments/assets/c578a79d-4be1-474f-8d75-a97712fae8b7" />

---

### 8. 🚀 Deploy the Project  
Once connected, deploy your new project to Vercel.

---

### 9. 🔐 Set the Webhook Secret  

Generate a secure token:

```bash
openssl rand -hex 32
```

Copy the result and replace `secretTokenProtectingWebhookEndpointsFromBeingCalledByAnyone` in:

- ✅ **Project Settings → Webhooks** (Invalidate Next.js Cache)
- ✅ **Configuration → Plugins** (2 plugin configs)

---

### 10. 🔧 Configure Vercel Environment Variables  

Set the following in your Vercel project settings:

| Key               | Value                                 |
|------------------|---------------------------------------|
| `SECRET_API_TOKEN` | The token you generated above         |
| `SITE_URL`         | Your deployed domain (e.g. `https://example.com`) |

> ⚠️ Do not include a trailing slash in `SITE_URL`.

---

### 11. 🔄 Redeploy the Project  

After setting env vars, trigger a new deployment on Vercel.

---

### 12. 💻 Clone the Repo Locally 

CONTENT HERE

---
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
