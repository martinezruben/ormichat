# Temporary pharmacy catalog used to demo automated product answers in the chat.
# Run with `bundle exec rake products:seed_sample[ACCOUNT_ID]`.
class Products::SampleCatalog
  IMAGE_PATH = '/product-samples'.freeze

  # rubocop:disable Layout/LineLength
  # [slug, name, brand, category, description, ai_description, [[variant name, price BOB, stock], ...]]
  PRODUCTS = [
    ['paracetamol-500', 'Paracetamol 500 mg', 'Genérico Farma', 'Analgésicos',
     'Tabletas para el alivio del dolor leve a moderado y la fiebre.',
     'Recomendar cuando el cliente busque alivio de dolor de cabeza, dolor leve de cuerpo, molestias por resfrío o fiebre. Es una opción suave para el estómago. Para adultos y niños mayores de 12 años; si es para un niño pequeño, embarazo o enfermedad crónica, derivar al farmacéutico.',
     [['Caja x 10 tabletas', 8.5, 120], ['Caja x 20 tabletas', 15.0, 64]]],
    ['ibuprofeno-400', 'Ibuprofeno 400 mg', 'Genérico Farma', 'Analgésicos',
     'Tabletas antiinflamatorias para dolor muscular, de cabeza y molestias articulares.',
     'Recomendar cuando el cliente busque algo para dolor muscular, de espalda, dental, menstrual o con inflamación. Conviene tomarlo con alimentos. No ofrecer a personas con problemas de estómago o riñón: derivar al farmacéutico.',
     [['Caja x 10 tabletas', 12.0, 80], ['Caja x 20 tabletas', 21.5, 3]]],
    ['loratadina-10', 'Loratadina 10 mg', 'Genérico Farma', 'Alergias',
     'Antihistamínico para el alivio de la rinitis alérgica y la urticaria.',
     'Recomendar cuando el cliente tenga estornudos, picazón de nariz u ojos, secreción nasal por alergia o ronchas en la piel. Suele causar poco sueño. Para adultos y niños mayores de 12 años.',
     [['Caja x 10 tabletas', 14.0, 45], ['Caja x 30 tabletas', 36.0, 18]]],
    ['jarabe-tos-infantil', 'Jarabe para la tos infantil', 'Pediafarma', 'Resfrío y tos',
     'Jarabe de miel y plantas para calmar la tos seca en niños.',
     'Recomendar cuando el cliente busque calmar la tos seca de un niño. Pregunta la edad: para menores de 2 años derivar al pediatra o al farmacéutico. Si la tos dura más de una semana o hay fiebre alta, sugerir consulta médica.',
     [['Frasco 100 ml', 32.0, 30], ['Frasco 200 ml', 54.0, 12]]],
    ['antiacido-masticable', 'Antiácido masticable', 'Digestia', 'Digestivos',
     'Tabletas masticables para el alivio de la acidez y la indigestión ocasional.',
     'Recomendar cuando el cliente tenga acidez, ardor en el estómago, pesadez o indigestión después de comer. Se mastica después de las comidas. Ofrece la variedad según el sabor que prefiera y avisa cuál está agotada.',
     [['Menta x 12', 9.0, 70], ['Fresa x 12', 9.0, 0], ['Naranja x 12', 9.0, 25]]],
    ['suero-oral', 'Suero oral de rehidratación', 'HidraPlus', 'Digestivos',
     'Sales de rehidratación oral en sobre para reponer líquidos y electrolitos.',
     'Recomendar cuando haya diarrea, vómitos o deshidratación leve, o tras mucho calor o ejercicio. Sirve para niños y adultos. Si hay mucha debilidad, sangre en las deposiciones o no tolera líquidos, sugerir atención médica.',
     [['Sabor neutro (sobre)', 6.5, 200], ['Sabor limón (sobre)', 7.0, 150], ['Pack x 6 sobres', 36.0, 22]]],
    ['vitamina-c-1000', 'Vitamina C 1000 mg efervescente', 'Vitalis', 'Vitaminas y suplementos',
     'Tabletas efervescentes de vitamina C para complementar la alimentación diaria.',
     'Recomendar cuando el cliente quiera reforzar su alimentación en épocas de resfríos o de cansancio. Se disuelve en agua. Es un complemento, no reemplaza una dieta variada.',
     [['Tubo x 10', 28.0, 55], ['Tubo x 20', 49.0, 4]]],
    ['multivitaminico-adulto', 'Multivitamínico adulto', 'Vitalis', 'Vitaminas y suplementos',
     'Complemento con vitaminas y minerales para adultos.',
     'Recomendar cuando el cliente busque un complemento diario de vitaminas y minerales por cansancio, dieta poco variada o falta de apetito. Es para adultos; no es para embarazadas sin consejo profesional.',
     [['Frasco x 30 cápsulas', 62.0, 40], ['Frasco x 60 cápsulas', 110.0, 16]]],
    ['crema-hidratante', 'Crema hidratante corporal', 'DermaCare', 'Cuidado de la piel',
     'Crema de uso diario para piel seca, con glicerina y vitamina E.',
     'Recomendar cuando el cliente tenga piel seca, áspera o con descamación, en codos, piernas y manos, sobre todo en clima frío o seco. Sirve para uso diario después del baño.',
     [['Pote 100 g', 25.0, 60], ['Pote 250 g', 48.0, 33]]],
    ['protector-solar-50', 'Protector solar FPS 50', 'DermaCare', 'Cuidado de la piel',
     'Protección alta contra rayos UVA y UVB, resistente al agua.',
     'Recomendar cuando el cliente vaya a exponerse al sol, a la playa o a la altura, o quiera proteger su cara a diario. Se aplica 20 minutos antes de salir y se repite cada 2 horas o después de nadar.',
     [['Tubo 60 ml', 78.0, 28], ['Tubo 120 ml', 135.0, 2]]],
    ['gotas-oculares', 'Gotas oculares lubricantes', 'OftalCare', 'Cuidado de ojos',
     'Solución lubricante para aliviar la sequedad e irritación ocular leve.',
     'Recomendar cuando el cliente sienta ojos secos, cansados o irritados por pantallas, aire acondicionado o lentes de contacto. Si hay dolor, secreción amarilla o la visión baja, sugerir consulta oftalmológica.',
     [['Frasco 10 ml', 38.0, 35], ['Frasco 15 ml', 52.0, 14]]],
    ['spray-nasal-salino', 'Spray nasal salino', 'RespiraBien', 'Resfrío y tos',
     'Solución salina para la higiene y descongestión nasal.',
     'Recomendar cuando el cliente tenga la nariz tapada, congestión por resfrío o alergia, o quiera lavar la nariz de un niño. El isotónico es de uso diario; el hipertónico descongestiona más.',
     [['Isotónico 30 ml', 27.0, 48], ['Hipertónico 30 ml', 31.0, 20]]],
    ['alcohol-gel', 'Alcohol en gel antibacterial', 'Higia', 'Higiene y protección',
     'Gel desinfectante de manos con 70% de alcohol.',
     'Recomendar cuando el cliente necesite limpiar sus manos fuera de casa o en el trabajo, cuando no hay agua y jabón. Elige el tamaño: 250 ml para llevar, 1 L para recargar. No usar sobre heridas abiertas.',
     [['Botella 250 ml', 14.0, 90], ['Botella 500 ml', 24.0, 55], ['Botella 1 L', 41.0, 0]]],
    ['termometro-digital', 'Termómetro digital', 'MediTech', 'Dispositivos',
     'Termómetro digital de lectura rápida con alarma de fiebre.',
     'Recomendar cuando el cliente quiera medir la temperatura en casa por fiebre o malestar. La punta flexible es más cómoda para niños y bebés.',
     [['Estándar', 45.0, 25], ['Punta flexible', 58.0, 11]]],
    ['tensiometro-brazo', 'Tensiómetro digital de brazo', 'MediTech', 'Dispositivos',
     'Medidor automático de presión arterial con memoria de lecturas.',
     'Recomendar cuando el cliente necesite controlar su presión arterial en casa, por ejemplo adultos mayores o personas con indicación médica de control. Para dudas sobre los valores, sugerir consultar a su médico.',
     [['Modelo básico', 285.0, 9], ['Modelo con voz', 349.0, 4]]],
    ['apositos-adhesivos', 'Apósitos adhesivos', 'CuraRapid', 'Primeros auxilios',
     'Tiras adhesivas para proteger cortes y raspaduras pequeñas.',
     'Recomendar cuando el cliente necesite proteger cortes pequeños, raspaduras o ampollas. Es útil tener una caja en casa, en el auto o en la mochila.',
     [['Caja x 20', 11.0, 140], ['Caja x 50', 24.0, 75]]],
    ['gasas-esteriles', 'Gasas estériles', 'CuraRapid', 'Primeros auxilios',
     'Gasas estériles de algodón para curaciones.',
     'Recomendar cuando el cliente necesite limpiar o cubrir heridas, hacer curaciones o cambiar un vendaje. Va bien con alcohol o suero y cinta adhesiva.',
     [['Paquete x 10', 8.0, 100], ['Paquete x 50', 32.0, 38]]],
    ['panales-bebe', 'Pañales para bebé', 'BabySoft', 'Bebés y maternidad',
     'Pañales descartables ultra absorbentes con indicador de humedad.',
     'Recomendar cuando el cliente busque pañales para un bebé. Pregunta el peso o la talla del bebé para elegir la variedad correcta y avisa qué tallas hay disponibles.',
     [['Talla M x 40', 89.0, 30], ['Talla G x 36', 92.0, 0], ['Talla XG x 32', 95.0, 19]]],
    ['shampoo-anticaspa', 'Shampoo anticaspa', 'DermaCare', 'Cuidado personal',
     'Shampoo de uso frecuente para controlar la caspa y la picazón del cuero cabelludo.',
     'Recomendar cuando el cliente tenga caspa, picazón o descamación del cuero cabelludo. Se usa 2 o 3 veces por semana. Si no mejora tras unas semanas, sugerir consulta dermatológica.',
     [['Frasco 200 ml', 36.0, 42], ['Frasco 400 ml', 62.0, 21]]],
    ['pasta-dental-fluor', 'Pasta dental con flúor', 'Sonríe', 'Cuidado personal',
     'Crema dental con flúor para la protección diaria contra las caries.',
     'Recomendar cuando el cliente busque protección diaria contra las caries y aliento fresco. Para adultos y niños mayores de 6 años; para menores, preguntar por pasta infantil.',
     [['Tubo 75 g', 12.0, 85], ['Tubo 150 g', 21.0, 47]]]
  ].freeze
  # rubocop:enable Layout/LineLength

  def self.seed!(account)
    PRODUCTS.map { |attrs| new(account, attrs).upsert! }
  end

  def initialize(account, attrs)
    @account = account
    @slug, @name, @brand, @category, @description, @ai_description, @variants = attrs
  end

  # Safe to repeat: creates what is missing and fills blank fields, never overwrites what the account edited.
  def upsert!
    product = @account.products.find_or_initialize_by(sku: sku)
    fill_blank(product, name: @name, brand: @brand, category: @category, description: @description,
                        ai_description: @ai_description, image_url: "#{IMAGE_PATH}/#{@slug}.svg")
    product.save!
    @variants.each_with_index { |variant, index| create_variant(product, variant, index) }
    product
  end

  private

  def sku
    "PH-#{@slug.upcase.tr('-', '_')}"
  end

  def fill_blank(product, attributes)
    attributes.each { |attribute, value| product[attribute] = value if product[attribute].blank? }
  end

  def create_variant(product, (name, price, stock), index)
    product.variants.find_or_create_by!(sku: "#{sku}-#{index + 1}") do |variant|
      variant.assign_attributes(name: name, price: price, stock: stock)
    end
  end
end
