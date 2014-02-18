## Boston Health Code Violation Map

The [csv parser](csv_parser.rb) accepts a csv file available [here](https://data.cityofboston.gov/Health/Food-Establishment-Inspections/qndu-wx8w) and spits out a JSON object with corrected text for use with the [http://leafletjs.com/](Leaflet) JavaScript mapping library.

The map has a search function thanks to [JQuery autocomplete](http://jqueryui.com/autocomplete/) and allows a user to browse violation counts and list violations for a specific restaurant.

See it [live](http://brycelambert.com/health-code/)