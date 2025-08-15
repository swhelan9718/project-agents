---
layout: default
title: Claude Development Guide
nav_exclude: true
description: "Internal guidance for Claude Code assistant"
---

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

GlobalViz is a Django-based bioinformatics platform for multi-omics data visualization and analysis. It provides statistical analysis, pathway enrichment, dimensionality reduction, clustering, and visualization tools for metabolomics, genomics, and microbiome data.

## Documentation

Comprehensive documentation is available in the `docs/` folder. Key documentation includes:

### Development

- **[Development Guide](docs/development/development.md)**: Complete setup, Docker workflow, local development
- **[Project Guidelines](docs/development/project_development_guidelines.md)**: Coding standards, import organization, typing conventions
- **[Linting Guide](docs/development/linting.md)**: Black for Python, Prettier for JS/CSS, djlint for Django templates
- **[Testing Guide](docs/testing/testing.md)**: Unit tests, integration tests, and Playwright E2E testing

### Features

- **[Generic Plot Framework](docs/features/generic_plot.md)**: Reusable plotting components with HTMX integration
- **[Feature Flags](docs/features/feature_flags.md)**: Django-flags for environment-based feature toggles

### Data & Operations

- **[Data Loading](docs/data/data_loading.md)**: Loading projects from FMS, importing JSON data
- **[Batch Processing](docs/data/batch.md)**: AWS Batch job management
- **[Multi-omics](docs/data/multi_omics.md)**: Multi-omics analysis workflows

For all documentation, see [docs/DOCS_GUIDE.md](docs/DOCS_GUIDE.md)

## Key Commands

### Development Setup

```bash
# Set PostgreSQL port (required for local development)
export POSTGRES_PORT=15432

poetry install                    # Install Python dependencies
npm install                      # Install JavaScript dependencies
poetry shell                     # Activate virtual environment (skip if in conda env)
./manage.py migrate              # Run database migrations
./manage.py runserver            # Start development server
npm run dev                      # Watch and rebuild frontend assets (webpack)
```

### Docker Development Options

**Option 1: Hybrid (Services in Docker, Django in IDE)**

```bash
# Start dependencies only
docker compose -f docker/docker-compose.yml up globalviz-aws-mock globalviz-postgres

# Then run Django from your IDE outside Docker (within poetry virtual environment)
# This allows for better debugging and faster iteration
```

**Option 2: Full Stack in Docker**

```bash
# Run complete application stack
docker compose -f docker/docker-compose.yml --profile required up -d

# Access at:
# - Django dev server: http://127.0.0.1:8001
# - Gunicorn server: http://127.0.0.1:8002
```

**Docker Test Execution**

```bash
# Run tests in Docker containers
docker compose -f docker/docker-compose.yml exec globalviz-django-app-local-dev bash -c "cd /local_app && ./run-tests.sh"

# Run specific test types in Docker
docker compose -f docker/docker-compose.yml exec globalviz-django-app-local-dev bash -c "cd /local_app && ./run-tests.sh --python-only"
docker compose -f docker/docker-compose.yml exec globalviz-django-app-local-dev bash -c "cd /local_app && ./run-tests.sh --unit-only"
```

### Testing

```bash
# Set PostgreSQL port for tests (required for database setup)
export POSTGRES_PORT=15432

# IMPORTANT: Use poetry run for running tests instead of conda activate
# The poetry virtual environment contains all the necessary dependencies

./run-tests.sh                   # Run all tests (Python + JavaScript)
./run-unit-tests.sh              # Run only unit tests
./run-tests.sh --python-only     # Run only Python tests
./run-tests.sh --js-only         # Run only JavaScript tests
./run-tests.sh --e2e-only        # Run only end-to-end tests (Playwright)
./run-tests.sh --integration-only # Run only integration tests
./run-tests.sh --skip-install    # Skip dependency installation
poetry run pytest -k test_name   # Run specific Python test (use poetry run!)
npm test                         # Run JavaScript tests with Jest

# Examples of running specific tests with poetry:
poetry run pytest -xvs path/to/test_file.py::TestClass::test_method
poetry run pytest -xvs async_jobs/batch/multiomics/test_job.py::TestBatchTransformEntrypoint::test_run
```

### Build and Assets

```bash
npm run build                    # Production webpack build
npm run dev                      # Development webpack build with watch
```

## Architecture Overview

### Technology Stack

- **Backend**: Django 4.2, Python 3.10+, PostgreSQL
- **Frontend**: Webpack, AlpineJS, HTMX, Plotly.js, Cytoscape.js
- **Data Science**: pandas, scikit-learn, scipy, MOPED (pathway analysis)
- **Infrastructure**: AWS (Batch, S3, ECR), Redis/Celery for async jobs
- **Testing**: pytest, Jest, Playwright for E2E

### Django App Structure

The codebase follows Django's app-based architecture with domain-specific apps:

- **`stats/`**: Core statistical analysis (PCA, PLS-DA, volcano plots, clustering)
- **`pathways/`**: Pathway enrichment analysis and network visualization
- **`multiomics/`**: Multi-omics integration and analysis
- **`microbiome/`**: Microbiome data processing and visualization
- **`lenses/`**: Custom data views and filters
- **`async_jobs/`**: Background job management and AWS Batch integration
- **`large_uploads/`**: S3-based file upload handling
- **`generic_plot/`**: Reusable plotting framework with HTMX forms
- **`forms/`**: Dynamic form generation utilities

### Key Design Patterns

1. **Async Job Processing**: Heavy computations run on AWS Batch, tracked via `AsyncJob` models with status polling
2. **JSONB Data Storage**: Analysis results stored in PostgreSQL JSONB fields for flexibility
3. **HTMX + AlpineJS Frontend**: Dynamic UI updates without full page reloads
4. **Generic Plot Framework**: Reusable components for creating interactive analysis interfaces
5. **Webpack Asset Pipeline**: Modular JavaScript builds with code splitting
6. **Feature Flags**: Django-flags for environment-based feature toggles (development, preprod, production)

### Development Conventions

- **Import Organization**: Standard library → third-party → local modules (alphabetical within groups)
- **Type Hints**: Use typed parameters with Optional, List, Union for all service functions
- **Return Values**: Return dictionaries instead of tuples for multi-value functions
- **Docstrings**: Google Style with minimal typing info (covered by type hints)
- **Code Formatting**: Black for Python, Prettier for JS/CSS, djlint for Django templates
- **Technology Stack Priority**: Django → HTMX → Alpine.js → JavaScript

### Data Flow Architecture

1. **Data Ingestion**: Files uploaded via `large_uploads` app to S3
2. **Processing**: Background jobs transform data and run statistical analyses
3. **Storage**: Results cached in JSONB fields, referenced by analysis models
4. **Visualization**: Frontend fetches processed data via API endpoints for plotting

### Frontend Organization

- **JavaScript Entry Points**: Defined in `webpack.config.js` for different app modules
- **Static Assets**: `static/javascript/` organized by Django app
- **Webpack Bundles**: Built to `static/webpack_bundles/` with content hashing
- **CSS**: SCSS files processed through webpack with MiniCssExtractPlugin

### Testing Strategy

- **Unit Tests**: pytest for Python, Jest for JavaScript
- **Integration Tests**: Marked with `@pytest.mark.integration`
- **E2E Tests**: Playwright for full user workflows
- **Test Data**: Fixtures in `tests/fixtures/` and factories in `*/factories.py`

### Environment Configuration

- **Settings**: `globalviz/settings.py` with environment-based configuration
- **Development**: Uses local PostgreSQL (port 15432 by default), Redis (port 16379)
- **AWS Integration**: Secrets Manager for production credentials, SSO authentication
- **Debug Mode**: Controlled via `DJANGO_DEBUG` environment variable
- **Local Auth**: Set `DUMMY_AUTH_ENABLED=TRUE` and `DEFAULT_LOGIN=myuser` for local testing
- **Feature Flags**: Use `./manage.py set_feature_flags development` for local development

### Common Development Tasks

- **Data Loading**: Use `./manage.py load_fms_project --file-locator <LOCATOR>` for importing projects
- **User Permissions**: `./manage.py add_user_to_projects --user myuser --all-projects` for local access
- **Database Reset**: Use `scripts/run-reload-globalviz-commands.sh` to reload database with demo data
- **Environment Detection**: Conda environments typically contain poetry; skip `poetry shell` if already in conda
- **Docker Services**: Start dependencies with `docker compose -f docker/docker-compose.yml up globalviz-aws-mock globalviz-postgres`
- **Batch Job Testing**: Build specific components with `./build.sh app|transform|statsbatch|multiomicsbatch`

### Git Commit Guidelines

- **IMPORTANT**: When creating git commits, DO NOT include any reference to Claude or AI assistance in the commit message
- Write commit messages as if they were written by the developer
- Focus on what was changed and why, not who or what helped create the changes

### Key File Locations

- **Main Settings**: `globalviz/settings.py`
- **URL Routing**: `*/urls.py` in each Django app
- **API Endpoints**: `*views_api.py` files
- **Models**: `*/models.py` defining database schema
- **Templates**: `*/templates/` with Django templates
- **Static Assets**: `static/javascript/` and `static/css/`
- **Test Configuration**: `pytest.ini`, `jest.config.js`
