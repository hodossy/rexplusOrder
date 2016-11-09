# rexplusOrder
Sketch Up plugin for exporting model to Rex-Plus order.

## Installation
Copy the rexplus_order.rb and rexplus_order folder to %AppData%\Roaming\SketchUp\SketchUp 2016\SketchUp\Plugins\ folder. Restart SketchUp.

## Personal information
Click Extensions -> Rexplus Order -> Set Personal Data and fill all needed information. Click Ok.

## Creating a model
This plugin only handles component definitions, therefore one must create a component for everything in the model which is needed in the order. Currently only 3 and 18 mm thick materials are considered. The description of the component should contain the detailed information.

| Keyword | Meaning |
| :-----: | :-----: |
| melamine | Colour code of the melamine (codes can be found in Help) |
| foilType | Colour code of the 0.2 mm thick edge foil (codes can be found in Help) |
| absType | Colour code of the 2 mm thick ABS (codes can be found in Help) |
| foilProfile | A number in format of [0-2][0-2], specifying how many edges should be banded of the longer and shorter side. 22 means banding of all edges. |
| absProfile | A number in format of [0-2][0-2], specifying how many edges should be banded of the longer and shorter side. 22 means banding of all edges. |
| skip | A component that is not part of the order |

## Exporting the order
When all components are defined properly in the description, click Extensions -> Rexplus Order -> Export to \*.rex and specify the folder where you want to save the order.
