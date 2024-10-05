gcc -c src/util.c -o src/util.o -I/opt/homebrew/include -DGL_SILENCE_DEPRECATION
gcc -c src/shader.c -o src/shader.o -I/opt/homebrew/include -DGL_SILENCE_DEPRECATION
#gcc -c src/graphics.c -o src/graphics.o -I/opt/homebrew/include -L/opt/homebrew/lib -lglfw -DGL_SILENCE_DEPRECATION
gcc -c src/graphics.c -o src/graphics.o -I/usr/local/include -I/opt/homebrew/include -DGL_SILENCE_DEPRECATION


swiftc main.swift shadertoy.swift src/graphics.o src/shader.o src/util.o -I Modules -I src -Xcc -I/usr/local/include -Xcc -I/opt/homebrew/include -L /opt/homebrew/lib -lglfw -framework OpenGL -o SwiftOpenGLApp -DGL_SILENCE_DEPRECATION
#swiftc main.swift src/graphics.o src/shader.o src/util.o -I Modules -I src -Xcc -I/usr/local/include -Xcc -I/opt/homebrew/include -L /usr/local/lib -lglfw -framework OpenGL -Xcc -DGL_SILENCE_DEPRECATION -o SwiftOpenGLApp

