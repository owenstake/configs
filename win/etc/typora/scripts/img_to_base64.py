import base64
import re
import os

def encode_images_to_base64(input_file, output_file):
    with open(input_file, 'r', encoding='utf-8') as md_file:
        html_content = md_file.read()

    # Find all image tags in the markdown content
    img_pattern = r'<img[^>]*\ssrc="([^"]+)"'
    image_tags = re.findall(img_pattern, html_content)

    for image_path in image_tags:
        # Check if the image path is relative or absolute
        if not os.path.isabs(image_path):
            image_path = os.path.join(os.path.dirname(input_file), image_path)

        if os.path.exists(image_path):
            with open(image_path, 'rb') as image_file:
                # Encode the image content to base64
                image_base64 = base64.b64encode(image_file.read()).decode('utf-8')

                # Replace the image path with the base64 encoded content in the markdown content
                html_content = html_content.replace(image_path, f'data:image/png;base64,{image_base64}')

    # Write the updated markdown content to the output file
    with open(output_file, 'w', encoding='utf-8') as html_file:
        html_file.write(html_content)

if __name__ == "__main__":
    import sys
    input_md_file = sys.argv[1]
    output_html_file = sys.argv[2]

    encode_images_to_base64(input_md_file, output_html_file)
