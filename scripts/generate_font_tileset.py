from PIL import Image, ImageDraw, ImageFont

# Generate image with ascii characters from $21 to $7E

text = ""
for i in range(0x20, 0x7F):
    text += chr(i)
image_width = 8 * len(text)
image = Image.new("RGB", (image_width, 8), color="white") # type: ignore
draw = ImageDraw.Draw(image)
font = ImageFont.truetype("scripts/Pixelchunk.ttf", 8)

draw.text((0, 0), text, "black", font=font)

image.save("build/img/characters.png")

