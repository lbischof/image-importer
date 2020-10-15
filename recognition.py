import sys
from PIL import Image, ImageDraw
import face_recognition
from face_recognition.face_recognition_cli import image_files_in_folder, scan_known_people
import numpy as np

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

def test_image(image_to_check, known_faces, known_face_encodings, tolerance=0.6):
        face_locations = face_recognition.face_locations(image_to_check)
        face_encodings = face_recognition.face_encodings(image_to_check, face_locations)
        img = Image.open(image_to_check)
        width, height = img.size

        for (top, right, bottom, left), face_encoding in zip(face_locations, face_encodings):
            matches = face_recognition.compare_faces(known_face_encodings, face_encoding)
            name = "Unknown"

            face_distances = face_recognition.face_distance(known_face_encodings, face_encoding)
            best_match_index = np.argmin(face_distances)
            if matches[best_match_index]:
                name = known_face_names[best_match_index]
            h = ((bottom-top))
            w = ((right-left))
            x = (w/2)+left
            y = (h/2)+top
            hp = h/height
            wp = w/width
            xp = x/width
            yp = y/height
            print("{{Area={{H={},W={},X={},Y={}}},Name={},Type=Face}}".format(hp,wp,xp,yp,name))



def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        eprint("USAGE")
        sys.exit(1)

    image_to_check = sys.argv[1]

    eprint("Looking for faces in {}".format(image_to_check))

    known_names, known_face_encodings = scan_known_people("/known")
    test_image(image_to_check, known_names, known_face_encodings)
