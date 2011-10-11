// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function showRangeMaps(){
  document.getElementById('rangemap').style.display='block';
  document.getElementById('population').style.display='none';
  document.getElementById('rangeMapLink').innerHTML="<span>Range Maps</span>";
  document.getElementById('populationTableLink').innerHTML="<a href='javascript:showPopulationTables()'>Population Tables</a>";
}

function showPopulationTables(){
  document.getElementById('rangemap').style.display='none';
  document.getElementById('population').style.display='block';
  document.getElementById('rangeMapLink').innerHTML="<a href='javascript:showRangeMaps()'>Range Maps</a>";
}