import setuptools

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setuptools.setup(
    name="ezai_util", # Replace with your own username
    version="0.0.1",
    author="Armando Fandango",
    author_email="armando@neurasights.com",
    description="Utilities for EZAI",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/armando-fandango/ezai_util",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: Apache Software License",
        "Operating System :: OS Independent",
        'Topic :: Scientific/Engineering',
        'Topic :: Scientific/Engineering :: Mathematics',
        'Topic :: Scientific/Engineering :: Artificial Intelligence',
        'Topic :: Software Development',
        'Topic :: Software Development :: Libraries',
        'Intended Audience :: Developers',
        'Intended Audience :: Education',
        'Intended Audience :: Science/Research',
    ],
    python_requires='>=3.6',
)