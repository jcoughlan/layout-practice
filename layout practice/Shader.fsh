//
//  Shader.fsh
//  temp
//
//  Created by James Coughlan on 05/02/2015.
//  Copyright (c) 2015 James Coughlan. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
