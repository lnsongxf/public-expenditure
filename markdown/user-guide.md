# A Quick User Guide

Before you start reading the book, here is a quick walkthrough of the structure of this book and how to use it. Hope this can help you make the most out of it.

## How the Book Works

This is an executable Jupyter book. Most sections of this book are written in Jupyter Notebook, which means they are a combination of code and markdown cells. This book not only shows how optimal policies are calculated, but also allows users to interact with our policy functions and see how they change under different macroeconomic environments by changing the inputs yourself.

## How to Run the Code

You can execute the notebooks online via `Binder`. What `Binder` does is hosting the notebooks on servers. This allows users to execute notebooks without having to download them and run them locally. To run the code online, simply click on the ![rocket](../images/rocket_logo.png) button on the top right of each Jupyter Notebook section. Note that you won't see this icon for certain pages, because they are not rendered from Jupyter Notebook.

Under the rocket button, there are two options. The first one says `Binder` and the second one says `Live Code`. Both options utilize a Binder Python kernel. The difference between the two is that `Binder` will launch a new page for you to run the code, whereas `Live Code` turns the current page into an interactive environment by using [Thebe](https://thebe.readthedocs.io/en/latest/). Both options allow you to modify the code and see how output changes. 

## Where the Source Code is Stored

The source code is hosted on [Github](https://github.com/pascalmichaillat/public-expenditure). You can also go to the Github repo by clicking the **repository** option  under the ![github](../images/github_logo.png) icon on the top right of the page. If you find something wrong with the code, or are confused about certain implementations, you can also raise an issue by clicking the **open issue** button. 

Once you are in the repo, you can find the notebooks in the `notebooks` folder. Output produced by the notebooks are stored in `notebooks/output/`.

## Where the Functions are Defined

Since we use one notebook for each section, and there are functions used by multiple notebooks, we decided to put all our reusable functions in the [Helper Functions](../notebooks/helpers) section. This section defines all the functions used in the chapter, and provides detailed documentation and references of how each function works. 

## How Users Can Contribute to the Book

If you are interested in contributing to the book, checkout [here](https://github.com/MarcDiethelm/contributing/blob/master/README.md) for a guide on how to contribute to Github projects and [this Wiki page](https://github.com/pascalmichaillat/public-expenditure/wiki/Jupyter-Book-Work-Flow-and-Tricks) for some useful Jupyter book tricks. We would love to have your input!