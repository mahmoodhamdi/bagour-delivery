import fs from 'fs';
import path from 'path';
import swaggerSpec from '../config/swagger';

const Converter = require('openapi-to-postmanv2');

/**
 * Generate Postman Collection from OpenAPI spec
 */
const generatePostmanCollection = async (): Promise<void> => {
  try {
    console.log('🚀 Generating Postman collection from OpenAPI spec...');

    const openApiSpec = JSON.stringify(swaggerSpec);

    const options = {
      defaultAuth: 'bearer',
      requestNameSource: 'url',
      indentCharacter: ' ',
      requestParametersResolution: 'schema',
      exampleParametersResolution: 'schema',
      folderStrategy: 'tags',
      includeAuthInfoInExample: true,
      parametersResolution: 'schema',
      optimizeConversion: true,
      stackLimit: 50,
      enableOptionalParameters: true,
      keepImplicitHeaders: false,
      shortValidationErrors: false,
      validationPropertiesToIgnore: [],
      showMissingInSchemaErrors: true,
    };

    Converter.convert(
      { type: 'string', data: openApiSpec },
      options,
      (err: Error | null, conversionResult: any) => {
        if (err || !conversionResult.result) {
          console.error('❌ Error converting OpenAPI to Postman:', err);
          return;
        }

        // Get the Postman collection
        const postmanCollection = conversionResult.output[0].data;

        // Enhance the collection with environment variables
        postmanCollection.variable = [
          {
            key: 'baseUrl',
            value: 'http://localhost:5000/api/v1',
            type: 'string',
            description: 'API base URL',
          },
          {
            key: 'accessToken',
            value: '',
            type: 'string',
            description: 'JWT access token - will be set automatically after login',
          },
          {
            key: 'refreshToken',
            value: '',
            type: 'string',
            description: 'JWT refresh token',
          },
          {
            key: 'customerId',
            value: '',
            type: 'string',
          },
          {
            key: 'restaurantId',
            value: '',
            type: 'string',
          },
          {
            key: 'driverId',
            value: '',
            type: 'string',
          },
          {
            key: 'orderId',
            value: '',
            type: 'string',
          },
        ];

        // Add auth configuration
        postmanCollection.auth = {
          type: 'bearer',
          bearer: [
            {
              key: 'token',
              value: '{{accessToken}}',
              type: 'string',
            },
          ],
        };

        // Add collection-level event scripts
        postmanCollection.event = [
          {
            listen: 'prerequest',
            script: {
              type: 'text/javascript',
              exec: [
                '// Pre-request script runs before every request',
                'console.log("Request to:", pm.request.url.toString());',
              ],
            },
          },
          {
            listen: 'test',
            script: {
              type: 'text/javascript',
              exec: [
                '// Test script runs after every request',
                'if (pm.response.code >= 200 && pm.response.code < 300) {',
                '    console.log("✓ Request successful");',
                '    ',
                '    // Auto-save tokens from login responses',
                '    if (pm.response.json() && pm.response.json().data) {',
                '        const data = pm.response.json().data;',
                '        ',
                '        if (data.accessToken) {',
                '            pm.collectionVariables.set("accessToken", data.accessToken);',
                '            console.log("✓ Access token saved");',
                '        }',
                '        ',
                '        if (data.refreshToken) {',
                '            pm.collectionVariables.set("refreshToken", data.refreshToken);',
                '            console.log("✓ Refresh token saved");',
                '        }',
                '        ',
                '        // Save user IDs',
                '        if (data.user && data.user._id) {',
                '            pm.collectionVariables.set("userId", data.user._id);',
                '        }',
                '        ',
                '        // Save created resource IDs',
                '        if (data._id) {',
                '            const url = pm.request.url.toString();',
                '            if (url.includes("/orders")) {',
                '                pm.collectionVariables.set("orderId", data._id);',
                '            } else if (url.includes("/restaurants")) {',
                '                pm.collectionVariables.set("restaurantId", data._id);',
                '            } else if (url.includes("/drivers")) {',
                '                pm.collectionVariables.set("driverId", data._id);',
                '            }',
                '        }',
                '    }',
                '} else {',
                '    console.log("✗ Request failed with status:", pm.response.code);',
                '}',
              ],
            },
          },
        ];

        // Write to file
        const outputPath = path.join(__dirname, '../../postman_collection.json');
        fs.writeFileSync(outputPath, JSON.stringify(postmanCollection, null, 2), 'utf-8');

        console.log('✅ Postman collection generated successfully!');
        console.log(`📁 Location: ${outputPath}`);
        console.log('\n📖 How to use:');
        console.log('1. Open Postman');
        console.log('2. Click "Import" button');
        console.log('3. Select the generated file: postman_collection.json');
        console.log('4. The collection will include all API endpoints with authentication');
        console.log('\n💡 Tips:');
        console.log('- After login, the access token is automatically saved');
        console.log('- Use collection variables to store IDs (orderId, restaurantId, etc.)');
        console.log('- All requests inherit Bearer token authentication\n');
      }
    );
  } catch (error) {
    console.error('❌ Error generating Postman collection:', error);
    process.exit(1);
  }
};

// Run the generator
generatePostmanCollection();
