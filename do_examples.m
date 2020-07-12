## do_examples
##
## Convert images in examples directory to ASCII art.

image_to_ascii ("examples/anatomy.jpg", 160, [7, 3],
  "m", 0,
  "output", "examples/anatomy.html"
);

image_to_ascii ("examples/bee.jpg", 160, [7, 3],
  "m", 2,
  "p", 1,
  "output", "examples/bee.html"
);

image_to_ascii ("examples/gish.jpg", 140,
  "m", 0.5,
  "output", "examples/gish.html"
);

image_to_ascii ("examples/moses.jpg", 120,
  "m", 1.5,
  "output", "examples/moses.html"
);

image_to_ascii ("examples/piano.jpg", 160,
  "output", "examples/piano.html"
);

image_to_ascii ("examples/truman.jpg", 120,
  "p", 2.3,
  "output", "examples/truman.html"
);

image_to_ascii ("examples/black.png", 79,
  "output", "examples/black.html"
);

image_to_ascii ("examples/white.png", 79,
  "output", "examples/white.html"
);
