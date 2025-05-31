from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

with open("requirements.txt", "r", encoding="utf-8") as fh:
    requirements = [line.strip() for line in fh if line.strip() and not line.startswith("#")]

setup(
    name="powerapp-yaml",
    version="1.0.0",
    author="PowerApp YAML Team",
    author_email="team@powerapp-yaml.com",
    description="Professional YAML handler for Power App components",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/powerapp/powerapp-yaml",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Topic :: Software Development :: Libraries :: Python Modules",
        "Topic :: Text Processing :: Markup",
    ],
    python_requires=">=3.8",
    install_requires=requirements,
    extras_require={
        "dev": ["pytest>=6.0", "black", "flake8", "mypy", "pre-commit"],
        "docs": ["mkdocs", "mkdocs-material", "mkdocs-autoapi"],
        "test": ["pytest", "pytest-cov", "pytest-benchmark", "coverage"],
    },
    entry_points={
        "console_scripts": [
            "powerapp-yaml=powerapp_yaml.cli:main",
        ],
    },
    include_package_data=True,
    package_data={
        "powerapp_yaml": ["templates/basic/*.yaml", "templates/advanced/*.yaml"],
    },
)
