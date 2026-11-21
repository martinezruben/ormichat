# Temporary pharmacy catalog used to demo automated product answers in the chat.
# Run with `bundle exec rake products:seed_sample[ACCOUNT_ID]`.
class Products::SampleCatalog
  IMAGE_PATH = '/product-samples'.freeze

  # [slug, name, brand, category, description, [[variant name, price BOB, stock], ...]]
  PRODUCTS = [
    ['paracetamol-500', 'Paracetamol 500 mg', 'Genérico Farma', 'Analgésicos',
     'Tabletas para el alivio del dolor leve a moderado y la fiebre.',
     [['Caja x 10 tabletas', 8.5, 120], ['Caja x 20 tabletas', 15.0, 64]]],
    ['ibuprofeno-400', 'Ibuprofeno 400 mg', 'Genérico Farma', 'Analgésicos',
     'Tabletas antiinflamatorias para dolor muscular, de cabeza y molestias articulares.',
     [['Caja x 10 tabletas', 12.0, 80], ['Caja x 20 tabletas', 21.5, 3]]],
    ['loratadina-10', 'Loratadina 10 mg', 'Genérico Farma', 'Alergias',
     'Antihistamínico para el alivio de la rinitis alérgica y la urticaria.',
     [['Caja x 10 tabletas', 14.0, 45], ['Caja x 30 tabletas', 36.0, 18]]],
    ['jarabe-tos-infantil', 'Jarabe para la tos infantil', 'Pediafarma', 'Resfrío y tos',
     'Jarabe de miel y plantas para calmar la tos seca en niños.',
     [['Frasco 100 ml', 32.0, 30], ['Frasco 200 ml', 54.0, 12]]],
    ['antiacido-masticable', 'Antiácido masticable', 'Digestia', 'Digestivos',
     'Tabletas masticables para el alivio de la acidez y la indigestión ocasional.',
     [['Menta x 12', 9.0, 70], ['Fresa x 12', 9.0, 0], ['Naranja x 12', 9.0, 25]]],
    ['suero-oral', 'Suero oral de rehidratación', 'HidraPlus', 'Digestivos',
     'Sales de rehidratación oral en sobre para reponer líquidos y electrolitos.',
     [['Sabor neutro (sobre)', 6.5, 200], ['Sabor limón (sobre)', 7.0, 150], ['Pack x 6 sobres', 36.0, 22]]],
    ['vitamina-c-1000', 'Vitamina C 1000 mg efervescente', 'Vitalis', 'Vitaminas y suplementos',
     'Tabletas efervescentes de vitamina C para complementar la alimentación diaria.',
     [['Tubo x 10', 28.0, 55], ['Tubo x 20', 49.0, 4]]],
    ['multivitaminico-adulto', 'Multivitamínico adulto', 'Vitalis', 'Vitaminas y suplementos',
     'Complemento con vitaminas y minerales para adultos.',
     [['Frasco x 30 cápsulas', 62.0, 40], ['Frasco x 60 cápsulas', 110.0, 16]]],
    ['crema-hidratante', 'Crema hidratante corporal', 'DermaCare', 'Cuidado de la piel',
     'Crema de uso diario para piel seca, con glicerina y vitamina E.',
     [['Pote 100 g', 25.0, 60], ['Pote 250 g', 48.0, 33]]],
    ['protector-solar-50', 'Protector solar FPS 50', 'DermaCare', 'Cuidado de la piel',
     'Protección alta contra rayos UVA y UVB, resistente al agua.',
     [['Tubo 60 ml', 78.0, 28], ['Tubo 120 ml', 135.0, 2]]],
    ['gotas-oculares', 'Gotas oculares lubricantes', 'OftalCare', 'Cuidado de ojos',
     'Solución lubricante para aliviar la sequedad e irritación ocular leve.',
     [['Frasco 10 ml', 38.0, 35], ['Frasco 15 ml', 52.0, 14]]],
    ['spray-nasal-salino', 'Spray nasal salino', 'RespiraBien', 'Resfrío y tos',
     'Solución salina para la higiene y descongestión nasal.',
     [['Isotónico 30 ml', 27.0, 48], ['Hipertónico 30 ml', 31.0, 20]]],
    ['alcohol-gel', 'Alcohol en gel antibacterial', 'Higia', 'Higiene y protección',
     'Gel desinfectante de manos con 70% de alcohol.',
     [['Botella 250 ml', 14.0, 90], ['Botella 500 ml', 24.0, 55], ['Botella 1 L', 41.0, 0]]],
    ['termometro-digital', 'Termómetro digital', 'MediTech', 'Dispositivos',
     'Termómetro digital de lectura rápida con alarma de fiebre.',
     [['Estándar', 45.0, 25], ['Punta flexible', 58.0, 11]]],
    ['tensiometro-brazo', 'Tensiómetro digital de brazo', 'MediTech', 'Dispositivos',
     'Medidor automático de presión arterial con memoria de lecturas.',
     [['Modelo básico', 285.0, 9], ['Modelo con voz', 349.0, 4]]],
    ['apositos-adhesivos', 'Apósitos adhesivos', 'CuraRapid', 'Primeros auxilios',
     'Tiras adhesivas para proteger cortes y raspaduras pequeñas.',
     [['Caja x 20', 11.0, 140], ['Caja x 50', 24.0, 75]]],
    ['gasas-esteriles', 'Gasas estériles', 'CuraRapid', 'Primeros auxilios',
     'Gasas estériles de algodón para curaciones.',
     [['Paquete x 10', 8.0, 100], ['Paquete x 50', 32.0, 38]]],
    ['panales-bebe', 'Pañales para bebé', 'BabySoft', 'Bebés y maternidad',
     'Pañales descartables ultra absorbentes con indicador de humedad.',
     [['Talla M x 40', 89.0, 30], ['Talla G x 36', 92.0, 0], ['Talla XG x 32', 95.0, 19]]],
    ['shampoo-anticaspa', 'Shampoo anticaspa', 'DermaCare', 'Cuidado personal',
     'Shampoo de uso frecuente para controlar la caspa y la picazón del cuero cabelludo.',
     [['Frasco 200 ml', 36.0, 42], ['Frasco 400 ml', 62.0, 21]]],
    ['pasta-dental-fluor', 'Pasta dental con flúor', 'Sonríe', 'Cuidado personal',
     'Crema dental con flúor para la protección diaria contra las caries.',
     [['Tubo 75 g', 12.0, 85], ['Tubo 150 g', 21.0, 47]]]
  ].freeze

  def self.seed!(account)
    PRODUCTS.map { |attrs| new(account, attrs).upsert! }
  end

  def initialize(account, attrs)
    @account = account
    @slug, @name, @brand, @category, @description, @variants = attrs
  end

  def upsert!
    product = @account.products.find_or_initialize_by(sku: sku)
    product.update!(name: @name, brand: @brand, category: @category, description: @description,
                    image_url: "#{IMAGE_PATH}/#{@slug}.svg", requires_prescription: false)
    @variants.each_with_index { |variant, index| upsert_variant(product, variant, index) }
    product
  end

  private

  def sku
    "PH-#{@slug.upcase.tr('-', '_')}"
  end

  def upsert_variant(product, (name, price, stock), index)
    record = product.variants.find_or_initialize_by(sku: "#{sku}-#{index + 1}")
    record.update!(name: name, price: price, stock: stock, currency: 'BOB')
  end
end
