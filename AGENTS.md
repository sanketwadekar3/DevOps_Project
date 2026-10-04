# Repository Guidelines

## Project Structure & Module Organization

`projects/boutique-microservices/` contains the application: the React frontend in `frontend/`, Node.js services in `backend/services/<service>/`, database initialization in `database/`, and local observability configuration in `prometheus/` and `grafana/`. `docker-compose.yml` runs the stack locally.

`gitops/` contains deployment configuration. Reusable Helm templates live in `gitops/charts/boutique-services/`; per-service Helm values are under `gitops/k8s/boutique-microservices/`. Namespace, database, and dashboard resources are managed by `gitops/kustomization.yml`; Argo CD values are in `gitops/argocd/`.

## Build, Test, and Development Commands

Run application commands from `projects/boutique-microservices/` (Node.js 20+):

```bash
npm run install:all     # install root, frontend, backend, and service packages
npm run dev             # start the frontend and backend development processes
npm run build           # build the frontend and TypeScript services
npm run docker:up       # build and start the Compose stack
npm run docker:down     # stop the Compose stack
```

Use `npm run test:frontend` for the React test suite. The root `npm test` also invokes backend service tests; several services do not yet define tests, so add a valid service test script before relying on that aggregate command. Validate deployment changes with:

```bash
helm lint gitops/charts/boutique-services -f gitops/k8s/boutique-microservices/auth.yaml
helm template auth gitops/charts/boutique-services -n boutique -f gitops/k8s/boutique-microservices/auth.yaml
```

## Coding Style & Naming Conventions

Follow the surrounding TypeScript/JavaScript style: two-space indentation, semicolons, single-quoted imports and strings, and camelCase identifiers. React components and context providers use PascalCase filenames (for example, `ProductCard.tsx`); service route files use lowercase names such as `routes/users.ts`. Keep each microservice self-contained under its service directory. The frontend uses Create React App's `react-app` ESLint configuration; no repository-wide formatter is configured.

For YAML, use two spaces and preserve the existing Helm values shape. Add a service using a lowercase, hyphenated directory and matching values file, such as `product-service/` and `product-service.yaml`.

## Testing, Commits & Pull Requests

Place frontend tests next to the covered component as `*.test.tsx` and use React Testing Library. Include tests for behavior changes and run the narrowest relevant build, test, or Helm validation before opening a PR.

Recent commits use brief imperative summaries and occasional Conventional Commit prefixes (for example, `ci: update image tags to b7d0a24`). Keep commits focused. PRs should describe application and manifest changes, link the relevant issue, note validation performed, and include screenshots for frontend changes. Never commit credentials: `gitops/secrets.yml` is intentionally ignored; reference Kubernetes Secrets instead.
