# cdext

[![License: MIT](https://img.shields.io)](https://opensource.org)

## Description

A simple powershell module for quickly changing directories. Directories can be saved using shortnames, and then referenced to later for quick traversal

## Getting Started

Navigate to a frequently used directory in powershell. Run the save <name> comand and specify the name you would like. CD to the home directory, and run the cdto <name> command. Enjoy! 
Simple help files are included. If anything is unclear or something should be added please leave an issue and I will update it accordiningly.

### Dependencies

N/A

### Installing

A step-by-step series of examples that tell you how to get a development environment running.

(wip) Pull the repo and run the .\build.ps1 script. Specifiy the directory to install the module in with the -Dir perameter. 
The defualt is under C:/User/<username>/Modules for windows. Linux is not supported yet.

## Usage

save <name> <path>  | path defualts to current directory if path is empty

remove <name>

cdto <name>

## License

This project is licensed under the MIT License - see the [`LICENSE.md`](LICENSE.md) file for details.

## Authors

Orion Newell 1/22/2026 

## Acknowledgments

*   Hat tip to anyone whose code was used
*   Inspiration and resources used

