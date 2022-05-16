import nibabel as nib
import numpy as np
from tqdm import tqdm
import matplotlib.pyplot as plt
from draw_lines import draw_lines
from PIL import Image
import tifffile

""" Reads a track (trk) file, then draws tracks in a 3D RGB image. Red tracks
are left-right, green are front-back, blue are top-bottom. Must define some
scaling parameter (see below) and the line weight (see below)."""


fname = 'whole_brain_MNI.trk'

# This scale parameter scales up the drawing board for the tracks, reltative
# to the original scan size. This will allow for better resolution on the
# lines. Note that the tracks in the original list are floats, and have 
# sub-voxel values.
scale = 4

# The radius of the track line, in voxels
line_weight = 1

trk = nib.streamlines.load(fname)

shape = tuple(scale*s for s in trk.header['dimensions']) + (3,)
X = np.zeros(shape, dtype='float32', order='F')

# The file defines the connectome paths relative to this offset. In the
# numpy array, we need to have all connectome coordinates relative to the
# origin in the top-left corner
offsets = trk.header['voxel_to_rasmm'][:3,3]

for stream in tqdm(trk.streamlines):
    stream -= offsets[None,:]

    # This line below is important. Applies scaling of coordinates, and
    # converts to a type acceptable by the fortran function.
    stream = np.asarray(scale*stream, dtype='float64', order='F')
    draw_lines(X, stream, line_weight)        


# This code block checks the different views.
fig, axes = plt.subplots(1,3)
for i in range(3):
    X_proj = np.mean(X, axis=i)
    X /= X.max()
    axes[i].imshow(X_proj)
fig.savefig('brain_fig.png')


# Save the output drawing as an OME-BigTIFF. This is the format which works
# in BisQue
X_uint8 = np.array(255*X, dtype='uint8', order='C')

Image.fromarray(X_uint8[300]).save('slice.png')

for i in range(3):
    tifffile.imwrite(
        f'brain_{i}.ome.tiff',
        np.swapaxes(X_uint8, 0, i),
        bigtiff=True,
        photometric='RGB',
        compression='zlib',
        metadata={
            'axes': 'ZYXS',
            'SignificantBits': 8,
        }
    )



