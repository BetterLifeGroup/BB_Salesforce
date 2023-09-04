@isTest
private class SRVPPLCreatePersonEmailAddressDtoTest {

    @isTest
    private static void equalsSameInstance() {
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto1 = SRVPPLCreatePersonEmailAddressDto.getExample();
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto2 = createPersonEmailAddressDto1;
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto3 = new SRVPPLCreatePersonEmailAddressDto();
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto4 = createPersonEmailAddressDto3;

        System.assert(createPersonEmailAddressDto1.equals(createPersonEmailAddressDto2));
        System.assert(createPersonEmailAddressDto2.equals(createPersonEmailAddressDto1));
        System.assert(createPersonEmailAddressDto1.equals(createPersonEmailAddressDto1));
        System.assert(createPersonEmailAddressDto3.equals(createPersonEmailAddressDto4));
        System.assert(createPersonEmailAddressDto4.equals(createPersonEmailAddressDto3));
        System.assert(createPersonEmailAddressDto3.equals(createPersonEmailAddressDto3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto1 = SRVPPLCreatePersonEmailAddressDto.getExample();
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto2 = SRVPPLCreatePersonEmailAddressDto.getExample();
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto3 = new SRVPPLCreatePersonEmailAddressDto();
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto4 = new SRVPPLCreatePersonEmailAddressDto();

        System.assert(createPersonEmailAddressDto1.equals(createPersonEmailAddressDto2));
        System.assert(createPersonEmailAddressDto2.equals(createPersonEmailAddressDto1));
        System.assert(createPersonEmailAddressDto3.equals(createPersonEmailAddressDto4));
        System.assert(createPersonEmailAddressDto4.equals(createPersonEmailAddressDto3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto1 = SRVPPLCreatePersonEmailAddressDto.getExample();
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto2 = new SRVPPLCreatePersonEmailAddressDto();

        System.assertEquals(false, createPersonEmailAddressDto1.equals('foo'));
        System.assertEquals(false, createPersonEmailAddressDto2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto1 = SRVPPLCreatePersonEmailAddressDto.getExample();
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto2 = new SRVPPLCreatePersonEmailAddressDto();
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto3;

        System.assertEquals(false, createPersonEmailAddressDto1.equals(createPersonEmailAddressDto3));
        System.assertEquals(false, createPersonEmailAddressDto2.equals(createPersonEmailAddressDto3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto1 = SRVPPLCreatePersonEmailAddressDto.getExample();
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto2 = new SRVPPLCreatePersonEmailAddressDto();

        System.assertEquals(createPersonEmailAddressDto1.hashCode(), createPersonEmailAddressDto1.hashCode());
        System.assertEquals(createPersonEmailAddressDto2.hashCode(), createPersonEmailAddressDto2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto1 = SRVPPLCreatePersonEmailAddressDto.getExample();
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto2 = SRVPPLCreatePersonEmailAddressDto.getExample();
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto3 = new SRVPPLCreatePersonEmailAddressDto();
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto4 = new SRVPPLCreatePersonEmailAddressDto();

        System.assert(createPersonEmailAddressDto1.equals(createPersonEmailAddressDto2));
        System.assert(createPersonEmailAddressDto3.equals(createPersonEmailAddressDto4));
        System.assertEquals(createPersonEmailAddressDto1.hashCode(), createPersonEmailAddressDto2.hashCode());
        System.assertEquals(createPersonEmailAddressDto3.hashCode(), createPersonEmailAddressDto4.hashCode());
    }

    @isTest
    private static void defaultValuesPopulated() {
        SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto = new SRVPPLCreatePersonEmailAddressDto();
        System.assertEquals(SRVPPLCreatePersonEmailAddressDto.TypeEnum.HOME, createPersonEmailAddressDto.type);
        System.assertEquals(null, createPersonEmailAddressDto.value);
        System.assertEquals(null, createPersonEmailAddressDto.isPrimary);
    }
}