## Plumber Example

Using plumber API to handle queries for:
- metadata
- data
- plot rendering

Plumber technical features:

- Using `{future}` to allow for async responses
- endpoints:
  - `/plot` :: returns HTML that can be embedded in a Web page
  - `/query` :: returns the data that supports the plot
  - `/ranges` :: returns metadata for the available date ranges
  - `/indexes` :: returns metadata that provides the available indexes in the data

Shiny:

- Calls Plumber API to retrieve metadata
- Plot is rendered by the browser (bypassing Shiny server)
  - Using an `iframe` HTML element
