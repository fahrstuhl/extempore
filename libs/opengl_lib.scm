;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Some OPENGL helper stuff
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(if (string=? (sys:platform) "Linux")
    (begin (llvm:compile "declare i32 @glGetUniformBlockIndex(i32, i8*);")
	   (llvm:compile "declare void @glUniformBlockBinding(i32, i32, i32);")
	   (llvm:compile "declare void @glBindBufferRange(i32,i32,i32,i32,i32);")))

(bind-val GL_ONE_MINUS_SRC_ALPHA i32 771)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load SOIL
(load "libs/image_lib.scm")

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load GL
(define libgl (if (string=? "Linux" (sys:platform))
		  (sys:open-dylib "/usr/lib/libGL.so")
		  (if (string=? "Windows" (sys:platform))
		      (sys:open-dylib "Gl32.dll")
		      (sys:open-dylib "/System/Library/Frameworks/OpenGL.framework/OpenGL"))))


;;;;;;;;;;;;;;;;;;;;;;;  FBO stuff
(bind-val GL_DRAW_FRAMEBUFFER i32 36009)
(bind-val GL_READ_FRAMEBUFFER i32 36008)
(bind-val GL_FRAMEBUFFER i32 36160)
(bind-val GL_RENDERBUFFER i32 36161)
(bind-val GL_RENDERBUFFER_WIDTH i32 36162)
(bind-val GL_RENDERBUFFER_HEIGHT i32 36163)
(bind-val GL_RENDERBUFFER_INTERNAL_FORMAT i32 36164)
(bind-val GL_FRAMEBUFFER_COMPLETE i32 36053)
(bind-val GL_COLOR_ATTACHMENT0 i32 36064)
(bind-val GL_COLOR_ATTACHMENT1 i32 36065)
(bind-val GL_COLOR_ATTACHMENT2 i32 36066)
(bind-val GL_COLOR_ATTACHMENT3 i32 36067)
(bind-val GL_COLOR_ATTACHMENT4 i32 36068)
(bind-val GL_COLOR_ATTACHMENT5 i32 36069)
(bind-val GL_COLOR_ATTACHMENT6 i32 36070)
(bind-val GL_COLOR_ATTACHMENT7 i32 36071)
(bind-val GL_COLOR_ATTACHMENT8 i32 36072)
(bind-val GL_COLOR_ATTACHMENT9 i32 36073)
(bind-val GL_COLOR_ATTACHMENT10 i32 36074)
(bind-val GL_COLOR_ATTACHMENT11 i32 36075)
(bind-val GL_COLOR_ATTACHMENT12 i32 36076)
(bind-val GL_COLOR_ATTACHMENT13 i32 36077)
(bind-val GL_COLOR_ATTACHMENT14 i32 36078)
(bind-val GL_COLOR_ATTACHMENT15 i32 36079)

(bind-val GL_DEPTH_ATTACHMENT i32 36096)
(bind-val GL_DEPTH_COMPONENT16 i32 33189)
(bind-val GL_DEPTH_COMPONENT24 i32 33190)
(bind-val GL_DEPTH_COMPONENT32 i32 33191)

(bind-val GL_VIEWPORT_BIT i32 2048)
(bind-val GL_ENABLE_BIT i32 8192)

(bind-lib libgl glGenFramebuffers [void,i32,i32*]*)
(bind-lib libgl glGenRenderbuffers [void,i32,i32*]*)
(bind-lib libgl glBindFramebuffer [void,i32,i32]*)
(bind-lib libgl glBindRenderbuffer [void,i32,i32]*)
(bind-lib libgl glRenderbufferStorage [void,i32,i32,i32,i32]*)
(bind-lib libgl glFramebufferRenderbuffer [void,i32,i32,i32,i32]*)
(bind-lib libgl glFramebufferTexture [void,i32,i32,i32,i32]*)
(bind-lib libgl glFramebufferTexture1D [void,i32,i32,i32,i32,i32]*)
(bind-lib libgl glFramebufferTexture2D [void,i32,i32,i32,i32,i32]*)
(bind-lib libgl glFramebufferTexture3D [void,i32,i32,i32,i32,i32,i32]*)
(bind-lib libgl glCheckFramebufferStatus [i32,i32]*)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load GLU
(define libglu (if (string=? "Linux" (sys:platform))
		   (sys:open-dylib "/usr/lib/libGLU.so")
		   (if (string=? "Windows" (sys:platform))
		       (sys:open-dylib "Glu32.dll")
		       (sys:open-dylib "/System/Library/Frameworks/OpenGL.framework/OpenGL"))))

(bind-lib libglu gluLookAt [void,double,double,double,double,double,double,double,double,double]*)
(bind-lib libglu gluPerspective [void,double,double,double,double]*)
(bind-lib libglu gluErrorString [i8*,i32]*)
			   


(definec gl-setup
  (lambda ()
    (glEnable GL_LIGHTING)
    (glEnable GL_LIGHT0)
    (let ((diffuse (heap-alloc 4 float))
	  (specular (heap-alloc 4 float))
	  (position (heap-alloc 4 float)))      
      (pset! diffuse 0 1.0)
      (pset! diffuse 1 1.0)
      (pset! diffuse 2 1.0)
      (pset! diffuse 3 1.0)
      (pset! specular 0 1.0)
      (pset! specular 2 1.0)
      (pset! specular 3 1.0)
      (pset! specular 4 1.0)
      (pset! position 0 100.0)
      (pset! position 1 100.0)
      (pset! position 2 100.0)
      (pset! position 3 0.0)

      (glLightfv GL_LIGHT0 GL_DIFFUSE diffuse)
      (glLightfv GL_LIGHT0 GL_SPECULAR specular)
      (glLightfv GL_LIGHT0 GL_POSITION position))

    (glColorMaterial GL_FRONT_AND_BACK GL_AMBIENT_AND_DIFFUSE)
    (glEnable GL_COLOR_MATERIAL)
    (glShadeModel GL_SMOOTH)
    (glDisable GL_BLEND)
    (glBlendFunc GL_ONE GL_SRC_ALPHA)))

(bind-val GL_MODELVIEW i32 5888)
(bind-val GL_MODELVIEW_MATRIX i32 2982)
(bind-val GL_PROJECTION i32 5889)
(bind-val GL_PROJECTION_MATRIX i32 2983)
(bind-val GL_TEXTURE i32 5890)
(bind-val GL_TEXTURE_MATRIX i32 2984)

(definec gl-set-view
  (lambda (w:double h:double depth:double)
    (glViewport 0 0 (dtoi32 w) (dtoi32 h))
    (glMatrixMode GL_PROJECTION)
    (glLoadIdentity)
    (gluPerspective 35.0 (/ w h) 1.0 depth)
    (glMatrixMode GL_MODELVIEW)
    (glEnable GL_DEPTH_TEST)
    (gl-setup)
    1))

(definec gl-look-at
  (lambda (eyex eyey eyez centre-x centre-y centre-z up-x up-y up-z)
    (glLoadIdentity)
    (gluLookAt eyex eyey eyez centre-x centre-y centre-z up-x up-y up-z)))


(define gl-load-extensions
  (lambda ()
    (if (string=? (sys:platform) "Windows")
	(begin (println "Loading OpenGL Extensions for Windows!!!!!")
	       (gl:add-extension "glGetShaderiv")
	       (gl:add-extension "glGetShaderInfoLog")
	       (gl:add-extension "glGetProgramiv")
	       (gl:add-extension "glGetProgramInfoLog")
	       (gl:add-extension "glCreateShader")
	       (gl:add-extension "glCreateProgram")
	       (gl:add-extension "glShaderSource")
	       (gl:add-extension "glCompileShader")
	       (gl:add-extension "glAttachShader")
	       (gl:add-extension "glLinkProgram")
	       (gl:add-extension "glUseProgram")
	       (gl:add-extension "glUniform1f")
	       (gl:add-extension "glUniform1i")	   
	       (gl:add-extension "glUniform2f")
	       (gl:add-extension "glUniform1fv")
	       (gl:add-extension "glUniform2fv")	   	   	   
	       (gl:add-extension "glGetUniformLocation")
	       (gl:add-extension "glGetUniformBlockIndex")
	       (gl:add-extension "glUniformBlockBinding")
	       (gl:add-extension "glBindBufferRange")
	       (gl:add-extension "glUniform3f")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; FBO helpers
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; creates an empty texture
;; suitable to back an FBO
(bind-func fbo_create_texture
  (lambda (width height)
    (let ((tex:i32* (salloc)))
      (glGenTextures 1 tex)
      (glBindTexture GL_TEXTURE_RECTANGLE_ARB (pref tex 0))
      (glTexImage2D GL_TEXTURE_RECTANGLE_ARB 0 GL_RGBA width height 0 GL_RGBA GL_UNSIGNED_BYTE null)
      (glTexParameteri GL_TEXTURE_RECTANGLE_ARB GL_TEXTURE_WRAP_S GL_CLAMP_TO_EDGE)
      (glTexParameteri GL_TEXTURE_RECTANGLE_ARB GL_TEXTURE_WRAP_T GL_CLAMP_TO_EDGE)
      (glTexParameteri GL_TEXTURE_RECTANGLE_ARB GL_TEXTURE_MAG_FILTER GL_LINEAR)
      (glTexParameteri GL_TEXTURE_RECTANGLE_ARB GL_TEXTURE_MIN_FILTER GL_LINEAR)
      (glBindTexture GL_TEXTURE_RECTANGLE_ARB 0)
      (pref tex 0))))


;; create fbo depth buffer
(bind-func fbo_create_depth_buffer
  (lambda (width height)
    (let ((id:i32* (salloc)))
      (glGenRenderbuffers 1 id)
      (glBindRenderbuffer GL_RENDERBUFFER (pref id 0))
      (glRenderbufferStorage GL_RENDERBUFFER GL_DEPTH_COMPONENT24 width height)
      (pref id 0))))

;; structure to hold fbo data
;; fbo id          0
;; texture id      1
;; depth buffer id 2
;; width           3
;; height          4
(bind-type E_fbo <i32,i32,i32,i32,i32>)

;; create and return a frame buffer struct (E_fbo)
(bind-func create-fbo
  (lambda (width:i32 height:i32)
    (let ((texid (fbo_create_texture width height))
	  (depthid (fbo_create_depth_buffer width height))
	  (fboid:i32* (salloc))
	  (fbo:E_fbo* (halloc))) ;; heap alloc
      (glGenFramebuffers 1 fboid)
      ;; bind the fbo
      (glBindFramebuffer GL_FRAMEBUFFER (pref fboid 0))
      (glFramebufferTexture2D GL_FRAMEBUFFER GL_COLOR_ATTACHMENT0 GL_TEXTURE_RECTANGLE_ARB texid 0); Attach the texture fbo_texture to the color buffer in our frame buffer
      (glFramebufferRenderbuffer GL_FRAMEBUFFER GL_DEPTH_ATTACHMENT GL_RENDERBUFFER depthid)
      (tfill! fbo (pref fboid 0) texid depthid width height)
      (let ((status:i32 (glCheckFramebufferStatus GL_FRAMEBUFFER)))
	(if (<> status GL_FRAMEBUFFER_COMPLETE)
	    (set! fbo (cast null E_fbo*))))
      ;; unbind the frame buffer
      (glBindFramebuffer GL_FRAMEBUFFER 0)
      ;; return the extfbo struct
      fbo)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Shader helpers
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; a couple of shader helper functions
(definec print-shader-info-log
  (lambda (obj:i32)
    (let ((infologLength (salloc 1 i32))
	  (charsWritten (salloc 1 i32)))
      (glGetShaderiv obj GL_INFO_LOG_LENGTH infologLength)
      (if (> (pref infologLength 0) 1)
	  (let ((log (bitcast (malloc (i32toi64 (pref infologLength 0))) i8*)))
	    (glGetShaderInfoLog obj (pref infologLength 0) charsWritten log)
	    (printf "printShaderInfoLog: %s\n" log)
	    (free log)
	    1)
	  (begin (printf "Shader Info log: OK\n") 1)))))

(definec print-program-info-log
  (lambda (obj:i32)
    (let ((infologLength (salloc 1 i32))
	  (charsWritten (salloc 1 i32)))
      (glGetProgramiv obj GL_INFO_LOG_LENGTH infologLength)
      (if (> (pref infologLength 0) 1)
	  (let ((log (bitcast (malloc (i32toi64 (pref infologLength 0))) i8*)))
	    (glGetProgramInfoLog obj (pref infologLength 0) charsWritten log)
	    (printf "printProgramInfoLog: %s\n" log)
	    (free log)
	    1)
	  (begin (printf "Program Info log: OK\n") 1)))))

;; load shader (vert and frag shader)
(definec create-shader
  (lambda (vsource:i8* fsource:i8*)
    (let ((fshader (glCreateShader GL_FRAGMENT_SHADER))
	  (vshader (glCreateShader GL_VERTEX_SHADER))
	  (fcode:|1,i8*|* (salloc 1))
	  (vcode:|1,i8*|* (salloc 1))
	  (program (glCreateProgram))
	  (temp:i32* (salloc 1)))
      (pset! fcode 0 fsource)
      (pset! vcode 0 vsource)      
      (glShaderSource fshader 1 (cast fcode i8**) (bitcast null i32*))
      (glShaderSource vshader 1 (cast vcode i8**) (bitcast null i32*))      
      (glCompileShader fshader)
      (glCompileShader vshader))    
      (glAttachShader program fshader)
      (glAttachShader program vshader)      
      (glLinkProgram program)
      (print-shader-info-log fshader)
      (print-shader-info-log vshader)
      (print-program-info-log program)
      program))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  GL DRAWING STUFF (deprecated use cairo)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(definec circle-line
  (lambda (radius:double x:double y:double)
    (let ((k 0.0))
      (glLineWidth 3.0)
      (glBegin GL_LINE_LOOP)
      (dotimes (k 90.0)
	(let ((angle:double (/ (* k 2.0 PI) 90.0)))
	  (glVertex2d (+ x (* (cos angle) radius)) (+ y (* (sin angle) radius)))))
      (glEnd))))

(definec circle-whole
  (lambda (radius:double x:double y:double)
    (let ((k 0.0))
      (glBegin GL_TRIANGLE_FAN)
      (dotimes (k 90.0)
	(let ((angle:double (/ (* k 2.0 PI) 90.0)))
	  (glVertex2d (+ x (* (cos angle) radius)) (+ y (* (sin angle) radius)))))
      (glEnd))))

(definec cube-whole
  (let ((dlist -1))
    (lambda ()
      (if (> dlist -1)
	  (begin (glCallList dlist) 1)
	  (begin (set! dlist (glGenLists 1))
		 (glNewList dlist (+ GL_COMPILE 1))
		 (glBegin GL_QUADS)
		 ;; Front face
		 (glNormal3d 0.0 0.0 1.0)
		 (glVertex3d 0.0 0.0  1.0)
		 (glVertex3d 1.0 0.0  1.0)
		 (glVertex3d 1.0  1.0  1.0)
		 (glVertex3d 0.0  1.0  1.0)
		 ;; Back face
		 (glNormal3d 0.0 0.0 -1.0)
		 (glVertex3d 0.0 0.0 0.0)
		 (glVertex3d 0.0  1.0 0.0)
		 (glVertex3d 1.0  1.0 0.0)
		 (glVertex3d 1.0 0.0 0.0)
		 ;; Top face
		 (glNormal3d 0.0 1.0 0.0)
		 (glVertex3d 0.0  1.0 0.0)
		 (glVertex3d 0.0  1.0  1.0)
		 (glVertex3d 1.0  1.0  1.0)
		 (glVertex3d 1.0  1.0 0.0)
		 ;; Bottom face
		 (glNormal3d 0.0 -1.0 0.0)
		 (glVertex3d 0.0 0.0 0.0)
		 (glVertex3d 1.0 0.0 0.0)
		 (glVertex3d 1.0 0.0  1.0)
		 (glVertex3d 0.0 0.0  1.0)
		 ;; Right face
		 (glNormal3d 1.0 0.0 0.0)
		 (glVertex3d 1.0 0.0 0.0)
		 (glVertex3d 1.0  1.0 0.0)
		 (glVertex3d 1.0  1.0  1.0)
		 (glVertex3d 1.0 0.0  1.0)
		 ;; Left face
		 (glNormal3d -1.0 0.0 0.0)
		 (glVertex3d 0.0 0.0 0.0)
		 (glVertex3d 0.0 0.0  1.0)
		 (glVertex3d 0.0  1.0  1.0)
		 (glVertex3d 0.0  1.0 0.0)
		 (glEnd)
		 (glEndList)
		 1)))))
