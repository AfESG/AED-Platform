## API documentation

`/api/[continents,regions,countries,populations,input_zones]`
List geographic entities with identifiers

`/api/continent/:id/regions`
`/api/region/:id/countries`
`/api/country/:iso_code/populations`
`/api/population/:id/input_zones`
`/api/input_zone/:id/strata`
Children for a particular geographic entity

`/api/[continent,region,country,population,input_zone,stratum]/[:id,:iso_code,:strcode]/geojson_map`
GeoJSON for a particular geographic entity

`/api/[continent,region,country]/[:id,:iso_code]/:year/[add,dpps]`
ADD or DPPS data for a particular geographic entity

`/api/input_zone/:id/data`
`/api/stratum/:strcode/data`
Raw data for an input zone or stratum

`/api/continent/:id/narrative`
`/api/region/:id/narrative`
`/api/country/:iso_code/narrative`
Narrative for continent, region, or country 

`/api/continent/:id/boilerplate_data`
`/api/region/:id/boilerplate_data`
`/api/country/:iso_code/boilerplate_data`
Narrative boilerplate data for continent, region, or country

`/api/range/known/geojson_map`
`/api/range/possible/geojson_map`
`/api/range/doubtful/geojson_map`
`/api/range/protected/geojson_map`
GeoJSON for known, possible, doubtful, and protected ranges

`/api/analysis/years`
List of available years for ADD and DPPS analyses

`/api/autocomplete`
List of all geographic entities to power an autocomplete feature

`/api/add_dump[.csv]`
Dump of all ADD summary data for all continents, regions, and countries

`/api/boilerplate_dump[.txt]`
Dump of narrative boilerplates for all continents, regions, and countries

`/api/boilerplate_data_dump[.csv]`
Dump of narrative boilerplate data for all continents, regions, and countries
