# Fetch El Torito
[![License](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://opensource.org/licenses/GPL-3.0)
![version](https://img.shields.io/badge/version-1.0-brightgreen)
[![PR's Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](http://makeapullrequest.com) 

Perl script which will extract the initial/default boot image from a CD if existent. It'll not extract any of other possibly existing boot images that are allowed by the El Torito standard.

The image data are written to STDOUT. All other information is written to
STDERR (Eg. Type and size of image). <br />
If you want to write the image to a file instead of STDOUT, you can
specify the filename wanted on the command-line using option -o <filename>

Call: 	 fetcheltorito CD-image > toritoimagefile <br />
Example: fetcheltorito /dev/sr0  > /tmp/bootimage

## Installation

[Download latest release version](https://github.com/swattle/fetch-el-torito/releases/download/v1.0/fetch-el-torito.zip).

The repo already comes with an executable and if that doesn't work, make the ```fetcheltorito.pl``` file an executable using ```sudo chmod +x fetcheltorito.pl``` in the command-line.

## License
This project is licensed under the GNU General Public License v3.0. Permissions of this strong copyleft license are conditioned on making available complete source code of licensed works and modifications, which include larger works using a licensed work, under the same license. Copyright and license notices must be preserved. Contributors provide an express grant of patent rights. Any material found which vandalises or threatens any sort of plagiarism will be strictly given a legal action.

 <p align="center"> Copyright (c) 2020 Swattle Inc. All rights reserved.</p>

## Contributing
- Fork this project by clicking the ```Fork``` button on top right corner of this page.
- Open terminal/console window. 
- Clone the repository by running following command in git:
 ```bash
$ git clone https://github.com/[YOUR-USERNAME]/fetch-el-torito.git
```
- Add all changes by running this command.
```bash
$ git add .
```
- Or to add specific files only, run this command.
```bash
$ git add path/to/your/file
```
- Commit changes by running these commands.
```bash
$ git commit -m "DESCRIBE YOUR CHANGES HERE"

$ git push origin
```
- Create a Pull Request by clicking the ```New pull request``` button on your repository page.

[![ForTheBadge built-with-love](http://ForTheBadge.com/images/badges/built-with-love.svg)](https://GitHub.com/swattle/) 
[![ForTheBadge powered-by-electricity](http://ForTheBadge.com/images/badges/powered-by-electricity.svg)](http://ForTheBadge.com)

<p align="center"> Copyright (c) 2020 Swattle Inc. All rights reserved.</p>
<p align="center"> Made with ❤ by <a href="https://github.com/swattle">Swattle</a></p>
