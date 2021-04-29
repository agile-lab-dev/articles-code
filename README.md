# Articles Code

This repository holds the source codes that are published in our articles.
For each article, there is an associated folder (with the same name of the article) which contains them.

In order to ease the process, you can use the script `carbon-image-generator.sh`. It takes the a folder, lists
all the files in it and produces:
- An output non-embedded Carbon image, to be used as a simple image
- An output embedded Carbon image, to be used only on Medium

## Usage

You can use the script as follow:

```bash
./carbon-image-generator.sh --sources <folder> 
```

This setups a docker for you, creates a subfolder named `carbon_images` under the specified `folder` and:
- for non-embedded images, it uses `carbon-now` to generate them
- for the embedded images, an URL is built using a theme applied to the source code files.

The subfolder `carbon_images` will contain:
- a set of PNG images produced from the source files
- a file named `embedded_images_links` which contains, for each image, the associated embedded URL to be used on Medium

### Details

By default, one file produces one embedded/non embedded image. For example, if the file is named `code.scala`, the resulting 
non-embedded PNG image will be named `code.png`.

However, if you have a single file which contains multiple sections, you can put your code only in a file and then produce `N` 
code images. 
This can be extremely useful if you have big chunks of code that "logically" fits together. 

You can do this by using the character `§` in your source code file. For example, if we have a file named `awesome.scala` like this:

```scala
val a = "wow"

§

val b = "incredible"
```

The tool will produce two images: `awesome_part0.png`, which will contain `val a = wow` and `awesome_part1.png` which will contain
`val b = "incredible"`. Of course, this also leads to the generation of two embedded URL's in the file `embedded_images_links`:

```bash
awesome_part0.png ---> URL
awesome_part1.png ---> URL
```

## How to contribute

In order to contribute, please fork this repo and create a Pull Request when ready.
- Create a branch named `feature/<article_name>` on your forked repo. The open a PR merging on `main`
- In the Pull Request, specify the link to the original issue of the article.
- The PR should contain a folder (named as the article) with all the sources under it
- Please, do not commit your generated images. The only files allowed are your source code files.
