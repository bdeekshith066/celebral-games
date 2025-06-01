import type { Schema, Struct } from '@strapi/strapi';

export interface SharedQuestion extends Struct.ComponentSchema {
  collectionName: 'components_shared_questions';
  info: {
    displayName: 'question';
  };
  attributes: {
    correct_option: Schema.Attribute.Integer;
    hint: Schema.Attribute.String;
    options: Schema.Attribute.JSON;
    text: Schema.Attribute.String;
  };
}

declare module '@strapi/strapi' {
  export module Public {
    export interface ComponentSchemas {
      'shared.question': SharedQuestion;
    }
  }
}
