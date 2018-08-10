# SceneCut: Joint Geometric and Object Segmentation for Indoor Scenes
![SceneCut](doc/SceneCut.png)

### Update:
- Add code to generate region hierarchies.
### Usage
- Run demo.m

### Generate region hierarchies from images/ucms
- Download and install COB network https://github.com/kmaninis/COB, place them at includes/COB. Make sure COB path is added.
- Pre-computed ucms for the NYU dataset can be downloaded from http://www.vision.ee.ethz.ch/~cvlsegmentation/cob/code.html. Otherwise run img2ucms function (in COB) to generate ucms.
- Run ucm2tree to generate region hierarchies and node features.

### Citation:
If you use this code, please consider citing the following papers:

    @Inproceedings{Pham2017,
       author = {{Pham}, T. and {Do}, T.-T. and {S{\"u}nderhauf}, N. and {Reid}, I.
        },
        title = "{SceneCut: Joint Geometric and Object Segmentation for Indoor Scenes}",
        booktitle={2018 IEEE International Conference on Robotics and Automation (ICRA)}, 
        year={2018}, 
    }
	
If you encounter any problems with the code, please contact the first author. Enjoy!