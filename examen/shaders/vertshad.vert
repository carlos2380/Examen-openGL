#version 330 core

in vec3 vertex;
in vec3 normal;

in vec3 matamb;
in vec3 matdiff;
in vec3 matspec;
in float matshin;

uniform mat4 proj;
uniform mat4 view;
uniform mat4 TG;

// Components que necessitareu declarar dels focus de llum
vec3 colFocus = vec3(1, 1, 1);
vec3 llumAmbient = vec3(0.3, 0.3, 0.3);
vec3 posFocus = vec3(3, 5, 3);  // en SCA

out vec3 fcolor;

vec3 Lambert (vec3 NormSCO, vec3 L) 
{
    // S'assumeix que els vectors que es reben com a paràmetres estan normalitzats

    // Inicialitzem color a component ambient
    vec3 colRes = llumAmbient * matamb;

    // Afegim component difusa, si n'hi ha
    if (dot (L, NormSCO) > 0)
      colRes = colRes + colFocus * matdiff * dot (L, NormSCO);
    return (colRes);
}

vec3 Phong (vec3 NormSCO, vec3 L, vec4 vertSCO) 
{
    // Els vectors estan normalitzats

    // Inicialitzem color a Lambert
    vec3 colRes = Lambert (NormSCO, L);

    // Calculem R i V
    if (dot(NormSCO,L) < 0)
      return colRes;  // no hi ha component especular

    vec3 R = reflect(-L, NormSCO); // equival a: normalize (2.0*dot(NormSCO,L)*NormSCO - L);
    vec3 V = normalize(-vertSCO.xyz);

    if ((dot(R, V) < 0) || (matshin == 0))
      return colRes;  // no hi ha component especular
    
    // Afegim la component especular
    float shine = pow(max(0.0, dot(R, V)), matshin);
    return (colRes + matspec * colFocus * shine); 
}

void main()
{	
   vec4 scovertex = view * TG * vec4(vertex, 1.0);
    //vec4 scovertex = view * vec4(vertex, 1.0);

    mat3 NormalMatrix = inverse (transpose (mat3 (view * TG)));


    vec3 sconormal = NormalMatrix*normal;

    //vec4 scofocus = vec4(posFocus, 1.0);
    vec4 scofocus = view*vec4(posFocus, 1.0);
    vec3 L = (scofocus - scovertex).xyz;

    sconormal = normalize(sconormal);

    L = normalize(L);

   fcolor = Lambert(sconormal, L);

   //fcolor = Phong(sconormal, L, scovertex);

    gl_Position = proj * view * TG * vec4 (vertex, 1.0);
}
