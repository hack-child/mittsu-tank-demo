require 'mittsu'

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
ASPECT = SCREEN_WIDTH.to_f / SCREEN_HEIGHT.to_f

scene = Mittsu::Scene.new
skybox_scene = Mittsu::Scene.new
camera = Mittsu::PerspectiveCamera.new(75.0, ASPECT, 0.1, 1000.0)
skybox_camera = Mittsu::PerspectiveCamera.new(75.0, ASPECT, 1.0, 100.0)

renderer = Mittsu::OpenGLRenderer.new width: SCREEN_WIDTH, height: SCREEN_HEIGHT, title: 'Hello World'
renderer.auto_clear = false

texture = Mittsu::ImageUtils.load_texture_cube(
  [ 'rt', 'lf', 'up', 'dn', 'bk', 'ft' ].map { |path|
    File.join File.dirname(__FILE__), "alpha-island_#{path}.png"
  }
)

shader = Mittsu::ShaderLib[:cube]
shader.uniforms['tCube'].value = texture

skybox_material = Mittsu::ShaderMaterial.new({
  fragment_shader: shader.fragment_shader,
  vertex_shader: shader.vertex_shader,
  uniforms: shader.uniforms,
  depth_write: false,
  side: Mittsu::BackSide
})

skybox = Mittsu::Mesh.new(Mittsu::BoxGeometry.new(100, 100, 100), skybox_material)
skybox_scene.add(skybox)

light = Mittsu::HemisphereLight.new(0xCCF2FF, 0x055E00, 0.5)
scene.add(light)

floor = Mittsu::Mesh.new(
  Mittsu::BoxGeometry.new(1000.0, 10.0, 1000.0),
  Mittsu::MeshPhongMaterial.new(color: 0xffffff)
)
floor.position.y = -5.0
scene.add(floor)

building = Mittsu::Mesh.new(
  Mittsu::BoxGeometry.new(5.0, 20.0, 5.0),
  Mittsu::MeshPhongMaterial.new(color: 0xffffff)
)
building.position.set(5.0, 10.0, 5.0)
scene.add(building)

tank = Mittsu::Mesh.new(
  Mittsu::BoxGeometry.new(0.5, 0.2, 0.7),
  Mittsu::MeshPhongMaterial.new(color: 0xffffff)
)
tank.position.y = 0.1
scene.add(tank)
turret = Mittsu::Mesh.new(
  Mittsu::BoxGeometry.new(0.3, 0.1, 0.3),
  Mittsu::MeshPhongMaterial.new(color: 0xffffff)
)
turret.position.y = 0.15
tank.add(turret)

camera.position.z = 5.0
camera.position.y = 1.0

turret.add(camera)

renderer.window.on_resize do |width, height|
  renderer.set_viewport(0, 0, width, height)
  camera.aspect = skybox_camera.aspect = width.to_f / height.to_f
  camera.update_projection_matrix
  skybox_camera.update_projection_matrix
end

renderer.window.run do
  if renderer.window.key_down?(GLFW_KEY_A)
    turret.rotation.y -= 0.1
    tank.rotation.y += 0.1
  end
  if renderer.window.key_down?(GLFW_KEY_D)
    turret.rotation.y += 0.1
    tank.rotation.y -= 0.1
  end
  if renderer.window.key_down?(GLFW_KEY_LEFT)
    turret.rotation.y += 0.1
  end
  if renderer.window.key_down?(GLFW_KEY_RIGHT)
    turret.rotation.y -= 0.1
  end
  if renderer.window.key_down?(GLFW_KEY_W)
    tank.translate_z(-0.1)
  end
  if renderer.window.key_down?(GLFW_KEY_S)
    tank.translate_z(0.1)
  end

  skybox_camera.quaternion.copy(camera.get_world_quaternion)

  renderer.clear
	renderer.render(skybox_scene, skybox_camera);
  renderer.clear_depth
  renderer.render(scene, camera)
end