# rexplusOrder
Sketch Up plugin for exporting model to Rex-Plus order.

## Installation
Copy the rexplus_order.rb and rexplus_order folder to %AppData%\Roaming\SketchUp\SketchUp 2016\SketchUp\Plugins\ folder. Restart SketchUp.

## Personal information
Click Extensions -> Rexplus Order -> Set Personal Data and fill all needed information. Click Ok.

## Creating a model
This plugin only handles component definitions, therefore one must create a component for everything in the model which is needed in the order. These components must only contain faces and edges, if a component contains other components, it will be skipped during exporting. (Furthermore, creating groups does not affect the order.) Currently only 3 and 18 mm thick materials are considered. The description of the component should contain the detailed information in keyword = value format, each in a new line.

| Keyword | Meaning |
| :-----: | :-----: |
| melamine | Colour code of the melamine (codes can be found in Help) |
| foilType | Colour code of the 0.2 mm thick edge foil (codes can be found in Help) |
| absType | Colour code of the 2 mm thick ABS (codes can be found in Help) |
| foilProfile | A number in format of [0-2][0-2], specifying how many edges should be banded of the longer and shorter side. 22 means banding of all edges. |
| absProfile | A number in format of [0-2][0-2], specifying how many edges should be banded of the longer and shorter side. 22 means banding of all edges. |
| skip | A component that is not part of the order |

Example:
>melamine = 2772  
>foilType = 279  
>foilProfile = 22  

## Exporting the order
When all components are defined properly in the description, click Extensions -> Rexplus Order -> Export to \*.rex and specify the folder where you want to save the order.

## Restrictions
Setting grain line orientation is currently not possible. Ordered items will have grain lines parallel to the longer side.

Components with sizes of 3 **AND** 18 mm are handled wrongly.
