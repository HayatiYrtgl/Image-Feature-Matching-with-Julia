using ImageFeatures
using Images
using Rotations, ImageDraw, CoordinateTransformations

# load the image
img = load("wp2788550-adventure-time-wallpaper-deviantart.jpg")

# img to grayscale
img1_gray = Gray.(img)

# rotation around
function rotation(image)

    # get the image and re center it
    rot = recenter(RotMatrix(5pi/6), [size(image)...].÷2)

    # transform the image
    transform = rot ∘ Translation(-50, -40)

    # regenerate the image
    image_regen = warp(image, transform, axes(image))

    # return the image
    return image_regen
end

# rotated image
img2 = rotation(img1_gray)

# key points calculation
function keypoints_calculation(image1, image2)
    # calculate the keypoints
    kp1 = Keypoints(fastcorners(image1, 12, 0.35))
    kp2 = Keypoints(fastcorners(image2, 12, 0.35))

    # return the keypoints
    return kp1, kp2
end

kp1, kp2 = keypoints_calculation(img1_gray, img2)

# Freak Descriptors
freak_params = FREAK()

# pass the image to the freak
desc1, ret1_kp = create_descriptor(img1_gray, kp1, freak_params)
desc2, ret2_kp = create_descriptor(img2, kp2, freak_params)

# draw the matches
matches = match_keypoints(ret1_kp, ret2_kp, desc1, desc2, 0.1)

# show the results
grid = hcat(img1_gray, img2)
offset = CartesianIndex(0, size(img1_gray, 2))
draw!(grid, [LineSegment(m[1], m[2] + offset) for m in matches])