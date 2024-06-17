import React from 'react';
import { SafeAreaView, Text } from 'react-native';
import CustomButton from './CustomButton';

const App = () => {
  return (
    <SafeAreaView>
      <Text>This is connected with react native :)</Text>
      <CustomButton />
    </SafeAreaView>
  );
};

export default App;
