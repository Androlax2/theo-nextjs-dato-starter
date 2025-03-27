# Theo NextJS Dato Starter

## Summary

- [How to use](#how-to-use)
    - [Quick start](#quick-start)
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

### How to use

#### Quick start

1. [Create an account on DatoCMS](https://datocms.com).

2. Make sure that you have set up the [Github integration on Vercel](https://vercel.com/docs/git/vercel-for-github).

3. Let DatoCMS set everything up for you clicking this button below:

[![Deploy with DatoCMS](https://dashboard.datocms.com/deploy/button.svg)](https://dashboard.datocms.com/deploy?repo=datocms%2Ftheo-nextjs-dato-starter%3Amain)

### Local setup

#### Set up environment variables

Copy the sample .env file:

```bash
cp .env.local.example .env.local
```

In your [DatoCMS' project](https://met-4883.admin.datocms.com/editor), go to the **Settings** menu at the top and click **API tokens**.

Copy the values of the following tokens into the specified environment variable:

- `DATOCMS_PUBLISHED_CONTENT_CDA_TOKEN`: CDA Only (Published)
- `DATOCMS_DRAFT_CONTENT_CDA_TOKEN`: CDA Only (Draft)
- `DATOCMS_CMA_TOKEN`: CMA Only (Admin)

Then set `SECRET_API_TOKEN` as a sicure string (you can use `openssl rand -hex 32` or any other cryptographically-secure random string generator). It will be used to safeguard all route handlers from incoming requests from untrusted sources:

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
}
```

## Updating the GraphQL schema

When the DatoCMS schema, which includes various models and fields, undergoes any updates or modifications, it is essential to ensure that these changes are properly reflected in your local development environment. To accomplish this, you should locally run the following command:

```
npm run generate-schema
```

Executing this task will automatically update the `schema.graphql` file for you. This crucial step ensures that gql.tada will have access to the most current and accurate version of the GraphQL schema, allowing your application to function correctly with the latest data structures and relationships defined within your DatoCMS setup.

## Storybook

### Local Storybook

To run Storybook locally, execute the following command:

```bash
npm run storybook
```

This will start Storybook on [http://localhost:6006](http://localhost:6006) where you can view and interact with your component library.

### GitHub Pages Storybook

The Storybook is also deployed to GitHub Pages. You can view it [here](https://signifly.github.io/met-web-next/).

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
