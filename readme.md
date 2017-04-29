# ![RealWorld Example App](logo.png)

> ### Nim codebase containing real world examples (CRUD, auth, advanced patterns, etc) that adheres to the [RealWorld](https://github.com/gothinkster/realworld-example-apps) spec and API.


### [Demo]()&nbsp;&nbsp;&nbsp;&nbsp;[RealWorld](https://github.com/gothinkster/realworld)


This codebase was created to demonstrate a fully fledged fullstack application built with **Nim** including CRUD operations, authentication, routing, pagination, and more.

We've gone to great lengths to adhere to the **Nim** community styleguides & best practices.

For more information on how to this works with other frontends/backends, head over to the [RealWorld](https://github.com/gothinkster/realworld) repo.


# How it works

For the latest version, please check out the `develop` branch.

# Getting started

## Setting up nim and nimble

First you need to set up the `nim` compiler and the `nimble` package manager. You can obtain them together from [official Nim site](https://nim-lang.org/).

## Building the project

The project can be built with the `nimble build` command executed from the project's root directory. In addition to the actual building process, `nimble` downloads the dependencies of the project.

For more information on the usage `nimble`, please see [nim-lang/nimble](https://github.com/nim-lang/nimble).

## Running the Conduit backend

There are two options available:

  1. Issue the `nimble build` command and then run the output binary placed in the `build` directory.
  1. Execute `nimble server` which builds the backend and spins up the server.