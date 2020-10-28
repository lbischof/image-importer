import sys
from PIL import Image
import face_recognition
from face_recognition.face_recognition_cli import image_files_in_folder, scan_known_people
import numpy as np

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

def test_image(image_to_check, known_names, known_face_encodings, tolerance=0.6):
        unknown_image = face_recognition.load_image_file(image_to_check)
        face_locations = face_recognition.face_locations(unknown_image)
        eprint("Done face_locations")
        face_encodings = face_recognition.face_encodings(unknown_image, face_locations)
        eprint("Done face_encoding")
        img = Image.open(image_to_check)
        width, height = img.size

        for (top, right, bottom, left), face_encoding in zip(face_locations, face_encodings):
            matches = face_recognition.compare_faces(known_face_encodings, face_encoding)
            eprint("Done compare_faces")
            name = "Unknown"

            face_distances = face_recognition.face_distance(known_face_encodings, face_encoding)
            eprint("Done face_distance")
            best_match_index = np.argmin(face_distances)
            if matches[best_match_index]:
                name = known_names[best_match_index]
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
