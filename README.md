# draw_connectome
Utility to convert a brain connectome trk (track) file to 3D voxels

## Get a sample .trk file
  1. Navigate to [this link](https://bisque2.ece.ucsb.edu/client_service/view?resource=https://bisque2.ece.ucsb.edu/data_service/00-HTRGSDQJ8H5qZvwXMgrb2i)
  2. Click "Download" on the toolbar
  3. Select "Original"

## Setup Repo and Environment
```bash
git clone github.com/michael-goebel/draw_connectome
cd draw_connectome
virtualenv -p python3 py3
source py3/bin/activate
pip install -r requirements.txt
mv ${PATH_TO_DOWNLOADS}/whole_brain_MNI.trk .  # Move sample trk file into repo directory
```

## Compile FORTRAN and run code
  1. Compile the FORTRAN code using ```python -m numpy.f2py -c -m draw_lines draw_lines.f```
      1. Check that there are no errors (warning are fine)
      2. Check that the .so file is created. Something similar to ```draw_lines.cpython-38-x86_64-linux-gnu.so```
  2. Run ```python test_draw.py```
      1. This should plot two thick line segments, and display the plot
      2. Check that this simple example works (see imgs/ directory), then move on to the actual connectome example
  3. Run ```python convert_trk_to_tiff.py```
      1. This may take up to a minute to run.
      2. Will save a figure, showing different projections of the connectome. Check this before moving on to the next step (again compare to file in imgs/ directory).
      3. Should also save a tiff file. This is the high resolution 3D image.

## Upload the output to BisQue
  1. Log into [BisQue](https://bisque2.ece.ucsb.edu)
  2. Upload the tiff file
  3. View the tiff file using all 3 viewers in BisQue - 2D slices, 3D volume, and movie player
